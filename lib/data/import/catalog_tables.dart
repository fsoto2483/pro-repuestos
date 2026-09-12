/// Las ocho tablas que componen el catalogo, con el nombre del archivo y las
/// columnas que se esperan en el CSV o el Excel.
///
/// Los encabezados estan en espanol porque quien mantiene estos archivos los
/// edita en Excel, no en el codigo.
enum CatalogTable {
  categories(
    fileName: 'categorias.csv',
    label: 'Categorias',
    required: <String>['id', 'nombre'],
    optional: <String>['descripcion', 'icono', 'color', 'orden'],
  ),
  partBrands(
    fileName: 'marcas_repuesto.csv',
    label: 'Marcas de repuesto',
    required: <String>['id', 'nombre'],
    optional: <String>['pais', 'tipo', 'logo_url'],
  ),
  vehicleMakes(
    fileName: 'marcas_vehiculo.csv',
    label: 'Marcas de vehiculo',
    required: <String>['id', 'nombre'],
    optional: <String>['pais'],
  ),
  vehicleModels(
    fileName: 'modelos.csv',
    label: 'Modelos',
    required: <String>['id', 'marca_id', 'nombre', 'ano_desde', 'ano_hasta'],
    optional: <String>['carroceria'],
  ),
  engines(
    fileName: 'motores.csv',
    label: 'Motores',
    required: <String>['id', 'modelo_id', 'codigo', 'nombre', 'ano_desde',
        'ano_hasta'],
    optional: <String>['cilindrada', 'combustible', 'potencia_hp'],
  ),
  products(
    fileName: 'productos.csv',
    label: 'Productos',
    required: <String>['id', 'sku', 'nombre', 'categoria_id',
        'marca_repuesto_id', 'precio'],
    optional: <String>['oem', 'descripcion', 'precio_anterior', 'stock',
        'garantia_meses', 'calificacion', 'numero_opiniones', 'destacado',
        'ficha_tecnica'],
  ),
  productImages(
    fileName: 'imagenes_productos.csv',
    label: 'Imagenes de productos',
    required: <String>['id', 'producto_id', 'url'],
    optional: <String>['orden', 'principal'],
  ),
  fitments(
    fileName: 'compatibilidades.csv',
    label: 'Compatibilidades',
    required: <String>['id', 'producto_id', 'modelo_id', 'ano_desde',
        'ano_hasta'],
    optional: <String>['motor_id'],
  );

  const CatalogTable({
    required this.fileName,
    required this.label,
    required this.required,
    required this.optional,
  });

  final String fileName;
  final String label;
  final List<String> required;
  final List<String> optional;

  List<String> get allColumns => <String>[...required, ...optional];

  /// Nombre sin extension, para reconocer tambien `productos.xlsx` o una hoja
  /// de Excel llamada `productos`.
  String get baseName => fileName.split('.').first;

  /// Busca la tabla que corresponde a un archivo u hoja por su nombre.
  static CatalogTable? matchName(String name) {
    final String clean = name
        .toLowerCase()
        .split('/')
        .last
        .split(r'\')
        .last
        .replaceAll(RegExp(r'\.(csv|xlsx|xls)$'), '')
        .trim();

    for (final CatalogTable table in CatalogTable.values) {
      if (clean == table.baseName) return table;
    }
    return null;
  }

  /// Orden en que hay que cargar las tablas para no violar las llaves
  /// foraneas: primero las que no dependen de nadie.
  static List<CatalogTable> get loadOrder => const <CatalogTable>[
    CatalogTable.categories,
    CatalogTable.partBrands,
    CatalogTable.vehicleMakes,
    CatalogTable.vehicleModels,
    CatalogTable.engines,
    CatalogTable.products,
    CatalogTable.productImages,
    CatalogTable.fitments,
  ];
}
