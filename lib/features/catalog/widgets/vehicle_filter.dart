import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/vehicle.dart';
import '../../../state/catalog_controller.dart';

/// Buscador por vehiculo: Marca -> Modelo -> Motor -> Ano.
///
/// Cada nivel solo se habilita cuando el anterior esta elegido, y al cambiar
/// un nivel se borran los de abajo. Asi nunca se puede armar una combinacion
/// que no exista, como un Spark con motor de Renault.
class VehicleFilterCard extends StatelessWidget {
  const VehicleFilterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CatalogController catalog = context.watch<CatalogController>();
    final bool hasVehicle = catalog.makeId != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.ink, AppColors.steel],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.directions_car_filled_rounded,
                color: AppColors.brand,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Busca por tu vehiculo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      hasVehicle
                          ? catalog.vehicleLabel
                          : 'Elige marca, modelo, motor y ano',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasVehicle)
                TextButton.icon(
                  onPressed: catalog.clearVehicle,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Quitar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const double spacing = 10;
              final int columns = constraints.maxWidth >= 860 ? 4 : 2;
              final double itemWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: <Widget>[
                  SizedBox(
                    width: itemWidth,
                    child: _CascadeField<String>(
                      label: 'Marca',
                      hint: 'Todas',
                      value: catalog.makeId,
                      enabled: catalog.makes.isNotEmpty,
                      items: <DropdownMenuItem<String>>[
                        for (final VehicleMake make in catalog.makes)
                          DropdownMenuItem<String>(
                            value: make.id,
                            child: Text(make.name),
                          ),
                      ],
                      onChanged: catalog.selectMake,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _CascadeField<String>(
                      label: 'Modelo',
                      hint: hasVehicle ? 'Todos' : 'Elige la marca',
                      value: catalog.modelId,
                      enabled: catalog.models.isNotEmpty,
                      items: <DropdownMenuItem<String>>[
                        for (final VehicleModel model in catalog.models)
                          DropdownMenuItem<String>(
                            value: model.id,
                            child: Text('${model.name} ${model.yearRange}'),
                          ),
                      ],
                      onChanged: catalog.selectModel,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _CascadeField<String>(
                      label: 'Motor',
                      hint: catalog.modelId == null
                          ? 'Elige el modelo'
                          : 'Todos',
                      value: catalog.engineId,
                      enabled: catalog.engines.isNotEmpty,
                      items: <DropdownMenuItem<String>>[
                        for (final Engine engine in catalog.engines)
                          DropdownMenuItem<String>(
                            value: engine.id,
                            child: Text(engine.name),
                          ),
                      ],
                      onChanged: catalog.selectEngine,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _CascadeField<int>(
                      label: 'Ano',
                      hint: catalog.modelId == null
                          ? 'Elige el modelo'
                          : 'Todos',
                      value: catalog.year,
                      enabled: catalog.years.isNotEmpty,
                      items: <DropdownMenuItem<int>>[
                        for (final int year in catalog.years)
                          DropdownMenuItem<int>(
                            value: year,
                            child: Text('$year'),
                          ),
                      ],
                      onChanged: catalog.selectYear,
                    ),
                  ),
                ],
              );
            },
          ),
          if (hasVehicle) ...<Widget>[
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Formatters.plural(
                      catalog.totalResults,
                      'repuesto compatible',
                      'repuestos compatibles',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Un nivel de la cascada. Deshabilitado se ve apagado y no se despliega.
class _CascadeField<T> extends StatelessWidget {
  const _CascadeField({
    required this.label,
    required this.hint,
    required this.value,
    required this.enabled,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final T? value;
  final bool enabled;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: enabled ? 0.7 : 0.35),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: enabled ? 0.1 : 0.04),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(14),
              // El menu va oscuro como la tarjeta: el texto de las opciones
              // usa el mismo estilo blanco del boton.
              dropdownColor: AppColors.inkSoft,
              focusColor: Colors.transparent,
              menuMaxHeight: 380,
              icon: Icon(
                Icons.expand_more_rounded,
                color: Colors.white.withValues(alpha: enabled ? 0.8 : 0.3),
              ),
              hint: Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: enabled ? 0.55 : 0.3),
                ),
              ),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              selectedItemBuilder: (BuildContext context) => <Widget>[
                for (final DropdownMenuItem<T> item in _entries)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DefaultTextStyle.merge(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: item.child,
                    ),
                  ),
              ],
              items: _entries,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }

  /// La primera opcion siempre limpia el nivel; sin ella no habria forma de
  /// volver atras una vez elegido un modelo.
  List<DropdownMenuItem<T>> get _entries => <DropdownMenuItem<T>>[
    DropdownMenuItem<T>(
      child: Text(
        hint,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
      ),
    ),
    ...items,
  ];
}
