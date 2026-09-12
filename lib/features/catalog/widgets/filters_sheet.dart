import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/part_category.dart';
import '../../../data/models/vehicle.dart';
import '../../../state/catalog_controller.dart';

/// Hoja inferior con el orden y los filtros del catalogo.
class FiltersSheet extends StatelessWidget {
  const FiltersSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const FiltersSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CatalogController catalog = context.watch<CatalogController>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Filtros y orden',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      catalog.resetFilters();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Limpiar todo'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text('Ordenar por', style: theme.textTheme.titleSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ProductSort.values.map((ProductSort option) {
                  final bool selected = catalog.sort == option;
                  return ChoiceChip(
                    label: Text(option.label),
                    selected: selected,
                    onSelected: (_) => catalog.setSort(option),
                    showCheckmark: false,
                    selectedColor: AppColors.brand,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),
              Text('Categoria', style: theme.textTheme.titleSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: catalog.categories.map((PartCategory category) {
                  final bool selected = catalog.categoryId == category.id;
                  return ChoiceChip(
                    avatar: Icon(
                      category.icon,
                      size: 16,
                      color: selected ? Colors.white : category.color,
                    ),
                    label: Text(category.name),
                    selected: selected,
                    onSelected: (_) => catalog.selectCategory(category.id),
                    showCheckmark: false,
                    selectedColor: category.color,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),
              Text(
                'Marca del repuesto',
                style: theme.textTheme.titleSmall,
              ),
              Text(
                'Quien fabrica la pieza, no el vehiculo.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: catalog.partBrands.map((PartBrand brand) {
                  final bool selected = catalog.partBrandId == brand.id;
                  return ChoiceChip(
                    label: Text('${brand.name} (${brand.productCount})'),
                    selected: selected,
                    onSelected: (_) => catalog.selectPartBrand(brand.id),
                    showCheckmark: false,
                    selectedColor: AppColors.ink,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: catalog.onlyAvailable,
                onChanged: (_) => catalog.toggleOnlyAvailable(),
                activeThumbColor: AppColors.brand,
                title: const Text('Solo productos disponibles'),
                subtitle: const Text('Oculta las referencias agotadas'),
              ),

              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Ver ${catalog.totalResults} resultados'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
