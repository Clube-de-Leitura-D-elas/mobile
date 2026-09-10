import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// Size variants for the dropdown trigger.
enum AppDropdownSize {
  md,
  lg,
}

/// Generic dropdown component for the Design System.
///
/// The selected value is controlled by the parent through [value].
/// The component owns only its internal UI state (open/closed).
///
/// When an item is selected:
/// - the menu closes;
/// - [onChanged] is called with the selected value.
///
/// Tapping outside the menu closes it without changing [value].
class AppDropdown<T> extends StatefulWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.hintText,
    this.enabled = true,
    this.size = AppDropdownSize.md,
    this.itemLabelBuilder,
  });

  /// Available options.
  final List<T> items;

  /// Currently selected value, controlled by the parent.
  final T? value;

  /// Called when the user selects an option.
  final ValueChanged<T> onChanged;

  /// Optional label displayed above the dropdown.
  final String? label;

  /// Text displayed when there is no selected value.
  final String? hintText;

  /// Whether the dropdown can be interacted with.
  final bool enabled;

  /// Size of the dropdown trigger.
  final AppDropdownSize size;

  /// Converts an item into the text displayed in the UI.
  ///
  /// If omitted, [T.toString] is used.
  final String Function(T item)? itemLabelBuilder;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _barrierEntry;
  OverlayEntry? _menuEntry;

  bool _isOpen = false;
  Size? _triggerSize;

  double get _height {
    switch (widget.size) {
      case AppDropdownSize.md:
        return 40.0;
      case AppDropdownSize.lg:
        return 56.0;
    }
  }

  EdgeInsets get _horizontalPadding {
    return const EdgeInsets.symmetric(horizontal: 16.0);
  }

  String _labelFor(T item) {
    return widget.itemLabelBuilder?.call(item) ?? item.toString();
  }

  void _toggle() {
    if (!widget.enabled) {
      return;
    }

    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.hasSize) {
      return;
    }

    _triggerSize = renderBox.size;
    _isOpen = true;

    _barrierEntry = OverlayEntry(
      builder: (_) {
        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: const SizedBox.expand(),
          ),
        );
      },
    );

    _menuEntry = OverlayEntry(
      builder: (_) {
        return CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(
            0,
            _triggerSize!.height + 4.0,
          ),
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          child: _DropdownMenu<T>(
            width: _triggerSize!.width,
            items: widget.items,
            selectedValue: widget.value,
            itemLabelBuilder: _labelFor,
            onSelected: _select,
          ),
        );
      },
    );

    overlay.insert(_barrierEntry!);
    overlay.insert(_menuEntry!);

    if (mounted) {
      setState(() {});
    }
  }

  void _close() {
    if (!_isOpen) {
      return;
    }

    _menuEntry?.remove();
    _barrierEntry?.remove();

    _menuEntry = null;
    _barrierEntry = null;
    _isOpen = false;

    if (mounted) {
      setState(() {});
    }
  }

  void _select(T value) {
    _close();
    widget.onChanged(value);
  }

  @override
  void didUpdateWidget(covariant AppDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enabled && _isOpen) {
      _close();
      return;
    }

    if (_isOpen && _menuEntry != null) {
      _menuEntry!.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _menuEntry?.remove();
    _barrierEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.text;
    final spacing = context.spacing;

    final textColor = widget.enabled
        ? colors.textDefault
        : colors.actionDisabledFg;

    final borderColor = widget.enabled
        ? (_isOpen
            ? colors.actionFocusRing
            : colors.borderDefault)
        : colors.actionDisabledBg;

    final backgroundColor = widget.enabled
        ? colors.bgDefault
        : colors.surfaceSunken;

    final trigger = CompositedTransformTarget(
      link: _layerLink,
      child: Semantics(
        button: true,
        enabled: widget.enabled,
        expanded: _isOpen,
        label: widget.label,
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.enabled ? _toggle : null,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              height: _height,
              padding: _horizontalPadding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: borderColor,
                  width: _isOpen ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.value == null
                          ? (widget.hintText ?? '')
                          : _labelFor(widget.value as T),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.bodyDefault.copyWith(
                        color: widget.value == null
                            ? colors.textMuted
                            : textColor,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.s8),
                  Icon(
                    _isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20.0,
                    color: textColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.label == null) {
      return trigger;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label!,
          style: typography.bodyDefaultEmphasis.copyWith(
            color: widget.enabled
                ? colors.textDefault
                : colors.actionDisabledFg,
          ),
        ),
        SizedBox(height: spacing.s4),
        trigger,
      ],
    );
  }
}

class _DropdownMenu<T> extends StatelessWidget {
  const _DropdownMenu({
    required this.width,
    required this.items,
    required this.selectedValue,
    required this.itemLabelBuilder,
    required this.onSelected,
  });

  final double width;
  final List<T> items;
  final T? selectedValue;
  final String Function(T item) itemLabelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.text;
    final spacing = context.spacing;

    return Material(
      color: colors.surfaceDefault,
      elevation: 8.0,
      shadowColor: colors.overlayScrim,
      borderRadius: BorderRadius.circular(8.0),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 280.0,
        ),
        child: SizedBox(
          width: width,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              vertical: spacing.s4,
            ),
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (_, __) {
              return Divider(
                height: 1.0,
                color: colors.borderDefault,
              );
            },
            itemBuilder: (context, index) {
              final item = items[index];
              final selected = item == selectedValue;

              return InkWell(
                onTap: () => onSelected(item),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 48.0,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.s16,
                    vertical: spacing.s8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          itemLabelBuilder(item),
                          style: typography.bodyDefault.copyWith(
                            color: selected
                                ? colors.textBrand
                                : colors.textDefault,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (selected)
                        Icon(
                          Icons.check,
                          size: 20.0,
                          color: colors.actionPrimary,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}