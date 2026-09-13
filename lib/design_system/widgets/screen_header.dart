import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'gap.dart';

enum ScreenHeaderVariant { simple, back, action }

class ScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  const ScreenHeader.simple({super.key, required this.title})
    : _variant = ScreenHeaderVariant.simple,
      onBackPressed = null,
      action = null;

  const ScreenHeader.back({super.key, required this.title, this.onBackPressed})
    : _variant = ScreenHeaderVariant.back,
      action = null;

  const ScreenHeader.action({
    super.key,
    required this.title,
    required Widget this.action,
  }) : _variant = ScreenHeaderVariant.action,
       onBackPressed = null;

  final String title;
  final VoidCallback? onBackPressed;
  final Widget? action;
  final ScreenHeaderVariant _variant;

  static const double _height = 56.0;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final spacing = context.spacing;

    return Container(
      color: colors.bgDefault,
      height: preferredSize.height,
      padding: EdgeInsets.symmetric(horizontal: spacing.s16),
      child: Row(
        children: [
          if (_variant == ScreenHeaderVariant.back) ...[
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.arrow_back, color: colors.textDefault),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              tooltip: 'Voltar',
            ),
            const Gap8(),
          ],
          Expanded(
            child: Text(
              title,
              style: text.headingH3.copyWith(color: colors.textDefault),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_variant == ScreenHeaderVariant.action) ...[
            const Gap8(),
            action!,
          ],
        ],
      ),
    );
  }
}

/* Exemplo de uso:
 
 Scaffold(
   appBar: ScreenHeader.simple(title: 'Início'),
   body: ...,
 ),
 
 Scaffold(
   appBar: ScreenHeader.back(title: 'Detalhe do livro'),
   body: ...,
 ),
 
 Scaffold(
   appBar: ScreenHeader.action(
     title: 'Meu clube',
     action: IconButton(
       icon: const Icon(Icons.notifications_none),
       onPressed: () => Navigator.pushNamed(context, '/notificacoes'),
     ),
   ),
   body: ...,
 ), */
