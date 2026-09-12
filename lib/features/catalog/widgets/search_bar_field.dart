import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Campo de busqueda rapida del catalogo.
///
/// Mantiene su propio `TextEditingController` sincronizado con el estado del
/// catalogo, para que al limpiar los filtros el texto tambien se limpie.
class SearchBarField extends StatefulWidget {
  const SearchBarField({
    super.key,
    required this.value,
    required this.onChanged,
    this.onFilterTap,
    this.filterCount = 0,
    this.hintText = 'Busca por nombre, SKU, OEM o marca',
    this.autofocus = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final int filterCount;
  final String hintText;
  final bool autofocus;

  @override
  State<SearchBarField> createState() => _SearchBarFieldState();
}

class _SearchBarFieldState extends State<SearchBarField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(SearchBarField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: widget.autofocus,
            textInputAction: TextInputAction.search,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: widget.value.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar busqueda',
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _controller.clear();
                        widget.onChanged('');
                      },
                    ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        if (widget.onFilterTap != null) ...<Widget>[
          const SizedBox(width: 10),
          _FilterButton(
            count: widget.filterCount,
            onPressed: widget.onFilterTap!,
          ),
        ],
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool active = count > 0;
    return Tooltip(
      message: 'Filtros y orden',
      child: SizedBox(
        width: 54,
        height: 54,
        child: Material(
          color: active
              ? AppColors.brand
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active
                      ? AppColors.brand
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Icon(
                    Icons.tune_rounded,
                    color: active ? Colors.white : AppColors.slate,
                  ),
                  if (active)
                    Positioned(
                      top: 9,
                      right: 9,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
