import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/db/app_database.dart';
import '../data/import/catalog_sources.dart';
import '../data/import/import_report.dart';
import '../data/models/catalog_filter.dart';
import '../data/models/part_category.dart';
import '../data/models/product.dart';
import '../data/models/vehicle.dart';
import '../data/repositories/catalog_repository.dart';

export '../data/models/catalog_filter.dart' show ProductSort, ProductSortLabel;

enum CatalogStatus { idle, loading, ready, error }

/// Estado del catalogo: filtros en cascada, resultados y favoritos.
///
/// Las consultas van a la base de datos, que es asincrona, pero la interfaz
/// necesita leer listas ya listas. Por eso el controlador guarda el ultimo
/// resultado y avisa con `notifyListeners` cuando cambia.
class CatalogController extends ChangeNotifier {
  CatalogController(this._repository);

  final CatalogRepository _repository;

  static const Duration _searchDebounce = Duration(milliseconds: 280);

  CatalogStatus _status = CatalogStatus.idle;
  String? _errorMessage;

  CatalogFilter _filter = const CatalogFilter();

  List<PartCategory> _categories = <PartCategory>[];
  List<VehicleMake> _makes = <VehicleMake>[];
  List<PartBrand> _partBrands = <PartBrand>[];

  List<VehicleModel> _models = <VehicleModel>[];
  List<Engine> _engines = <Engine>[];
  List<int> _years = <int>[];

  List<Product> _results = <Product>[];
  List<Product> _featured = <Product>[];
  int _totalResults = 0;
  bool _searching = false;

  CatalogStats? _stats;
  final Set<String> _favorites = <String>{};

  Timer? _debounce;
  bool _disposed = false;

  /// Cada busqueda lleva un numero. Si vuelve una respuesta vieja porque la
  /// base tardo mas de lo normal, se descarta en vez de pisar la nueva.
  int _searchToken = 0;

  // ---------------------------------------------------------------- estado

  CatalogStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading =>
      _status == CatalogStatus.loading || _status == CatalogStatus.idle;
  bool get isSearching => _searching;

  CatalogFilter get filter => _filter;
  CatalogStats? get stats => _stats;

  List<PartCategory> get categories => _categories;
  List<VehicleMake> get makes => _makes;
  List<PartBrand> get partBrands => _partBrands;
  List<VehicleModel> get models => _models;
  List<Engine> get engines => _engines;
  List<int> get years => _years;

  List<Product> get results => _results;
  List<Product> get featured => _featured;
  int get totalResults => _totalResults;

  String get query => _filter.query;
  String? get categoryId => _filter.categoryId;
  ProductSort get sort => _filter.sort;
  bool get onlyAvailable => _filter.onlyAvailable;

  String? get makeId => _filter.makeId;
  String? get modelId => _filter.modelId;
  String? get engineId => _filter.engineId;
  int? get year => _filter.year;
  String? get partBrandId => _filter.partBrandId;

  int get activeFilterCount => _filter.activeCount;
  bool get hasActiveFilters => !_filter.isEmpty;

  PartCategory? get selectedCategory => _find(_categories, _filter.categoryId);
  VehicleMake? get selectedMake => _find(_makes, _filter.makeId);
  VehicleModel? get selectedModel => _find(_models, _filter.modelId);
  Engine? get selectedEngine => _find(_engines, _filter.engineId);
  PartBrand? get selectedPartBrand => _find(_partBrands, _filter.partBrandId);

  /// "Chevrolet Spark GT 1.2 · 2015", para mostrar el vehiculo elegido.
  String get vehicleLabel {
    if (selectedMake == null) return 'Todos los vehiculos';
    final List<String> parts = <String>[
      selectedMake!.name,
      if (selectedModel != null) selectedModel!.name,
      if (selectedEngine != null) selectedEngine!.name,
    ];
    final String vehicle = parts.join(' ');
    return _filter.year == null ? vehicle : '$vehicle · ${_filter.year}';
  }

  // ----------------------------------------------------------------- carga

  Future<void> load() async {
    _status = CatalogStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.ensureSeeded();

      _categories = await _repository.fetchCategories();
      _makes = await _repository.fetchMakes();
      _partBrands = await _repository.fetchPartBrands();
      _featured = await _repository.fetchFeatured();
      _stats = await _repository.stats();

      await _runSearch();
      _status = CatalogStatus.ready;
    } catch (e) {
      _errorMessage =
          'No pudimos abrir el catalogo local. Cierra la aplicacion y '
          'vuelve a intentarlo.';
      _status = CatalogStatus.error;
      debugPrint('CatalogController.load: $e');
    }
    notifyListeners();
  }

  Future<void> reload() => load();

  // --------------------------------------------------------------- filtros

  void search(String value) {
    if (_filter.query == value) return;
    _filter = _filter.copyWith(query: value);
    notifyListeners();

    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      unawaited(_runSearch(notify: true));
    });
  }

  void clearSearch() => search('');

  void selectCategory(String? id) {
    final bool clear = id == null || _filter.categoryId == id;
    _apply(_filter.copyWith(categoryId: id, clearCategory: clear));
  }

  void setSort(ProductSort value) {
    if (_filter.sort == value) return;
    _apply(_filter.copyWith(sort: value));
  }

  void toggleOnlyAvailable() {
    _apply(_filter.copyWith(onlyAvailable: !_filter.onlyAvailable));
  }

  void selectPartBrand(String? id) {
    final bool clear = id == null || _filter.partBrandId == id;
    _apply(_filter.copyWith(partBrandId: id, clearPartBrand: clear));
  }

  void resetFilters() {
    _debounce?.cancel();
    _filter = const CatalogFilter();
    _models = <VehicleModel>[];
    _engines = <Engine>[];
    _years = <int>[];
    unawaited(_runSearch(notify: true));
    notifyListeners();
  }

  // ------------------------------------------------- cascada del vehiculo

  /// Marca del vehiculo. Al cambiarla se caen modelo, motor y ano, porque un
  /// Spark no existe dentro de Renault.
  Future<void> selectMake(String? id) async {
    if (id == null || _filter.makeId == id) {
      clearVehicle();
      return;
    }

    _filter = _filter.copyWith(
      makeId: id,
      clearModel: true,
      clearEngine: true,
      clearYear: true,
    );
    _engines = <Engine>[];
    _years = <int>[];
    notifyListeners();

    _models = await _repository.fetchModels(id);
    notifyListeners();
    await _runSearch(notify: true);
  }

  Future<void> selectModel(String? id) async {
    if (id == null || _filter.modelId == id) {
      _filter = _filter.copyWith(
        clearModel: true,
        clearEngine: true,
        clearYear: true,
      );
      _engines = <Engine>[];
      _years = <int>[];
      notifyListeners();
      await _runSearch(notify: true);
      return;
    }

    _filter = _filter.copyWith(
      modelId: id,
      clearEngine: true,
      clearYear: true,
    );
    notifyListeners();

    _engines = await _repository.fetchEngines(id);
    _years = await _repository.fetchYears(modelId: id);
    notifyListeners();
    await _runSearch(notify: true);
  }

  Future<void> selectEngine(String? id) async {
    final bool clear = id == null || _filter.engineId == id;
    _filter = _filter.copyWith(
      engineId: id,
      clearEngine: clear,
      clearYear: true,
    );
    notifyListeners();

    if (_filter.modelId != null) {
      // El motor acota los anos: un 1.6 puede haber salido despues que el 1.2.
      _years = await _repository.fetchYears(
        modelId: _filter.modelId!,
        engineId: _filter.engineId,
      );
    }
    notifyListeners();
    await _runSearch(notify: true);
  }

  void selectYear(int? value) {
    final bool clear = value == null || _filter.year == value;
    _apply(_filter.copyWith(year: value, clearYear: clear));
  }

  void clearVehicle() {
    _models = <VehicleModel>[];
    _engines = <Engine>[];
    _years = <int>[];
    _apply(
      _filter.copyWith(
        clearMake: true,
        clearModel: true,
        clearEngine: true,
        clearYear: true,
      ),
    );
  }

  // ------------------------------------------------------------- consultas

  Future<List<Product>> productsInCategory(
    String categoryId, {
    String query = '',
  }) {
    return _repository.search(
      CatalogFilter(categoryId: categoryId, query: query),
    );
  }

  Future<Product?> fullProduct(String id) => _repository.fetchProductById(id);

  Future<List<Product>> relatedTo(Product product) =>
      _repository.relatedTo(product);

  int countForCategory(String id) => _find(_categories, id)?.productCount ?? 0;

  /// Sugerencias mostradas debajo del buscador mientras se escribe.
  List<Product> suggestions({int limit = 6}) {
    if (_filter.query.trim().length < 2) return const <Product>[];
    return _results.take(limit).toList();
  }

  // ------------------------------------------------------------ favoritos

  Set<String> get favoriteIds => Set<String>.unmodifiable(_favorites);

  List<Product> get favorites =>
      _results.where((Product p) => _favorites.contains(p.id)).toList();

  int get favoriteCount => _favorites.length;

  bool isFavorite(String id) => _favorites.contains(id);

  void toggleFavorite(String id) {
    if (!_favorites.add(id)) _favorites.remove(id);
    notifyListeners();
  }

  // ---------------------------------------------------------- carga masiva

  /// Reemplaza el catalogo con archivos CSV o Excel y recarga la pantalla.
  Future<ImportReport> importFiles(List<SourceFile> files) async {
    final ImportReport report = await _repository.importFiles(files);
    if (report.applied) await load();
    return report;
  }

  Future<ImportReport> restoreBundledCatalog() async {
    final ImportReport report = await _repository.restoreBundled();
    if (report.applied) await load();
    return report;
  }

  // --------------------------------------------------------------- interno

  void _apply(CatalogFilter next) {
    if (next == _filter) return;
    _filter = next;
    notifyListeners();
    unawaited(_runSearch(notify: true));
  }

  Future<void> _runSearch({bool notify = false}) async {
    final int token = ++_searchToken;
    _searching = true;
    if (notify) notifyListeners();

    try {
      final List<Product> found = await _repository.search(_filter);
      final int total = await _repository.count(_filter);
      if (token != _searchToken) return;

      _results = found;
      _totalResults = total;
    } catch (e) {
      if (token != _searchToken) return;
      _results = <Product>[];
      _totalResults = 0;
      debugPrint('CatalogController._runSearch: $e');
    } finally {
      if (token == _searchToken) {
        _searching = false;
        if (notify) notifyListeners();
      }
    }
  }

  static T? _find<T extends Object>(List<T> items, String? id) {
    if (id == null) return null;
    for (final T item in items) {
      if (_idOf(item) == id) return item;
    }
    return null;
  }

  static String _idOf(Object item) => switch (item) {
    PartCategory c => c.id,
    VehicleMake m => m.id,
    VehicleModel m => m.id,
    Engine e => e.id,
    PartBrand b => b.id,
    _ => '',
  };

  /// Una consulta puede terminar despues de que la pantalla se cerro; avisar
  /// entonces revienta, asi que se descarta en silencio.
  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
