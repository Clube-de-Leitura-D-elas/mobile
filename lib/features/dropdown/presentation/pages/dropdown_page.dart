import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/design_system/widgets/app_dropdown.dart';
import 'package:mobile/features/dropdown/presentation/cubit/dropdown_cubit.dart';
import 'package:mobile/features/dropdown/presentation/cubit/dropdown_state.dart';

class DropdownPreviewPage extends StatelessWidget {
  const DropdownPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DropdownPreviewCubit(),
      child: const _DropdownPreviewView(),
    );
  }
}

class _DropdownPreviewView extends StatelessWidget {
  const _DropdownPreviewView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final spacing = context.spacing;
    final l10n = context.l10n;

    final genreEntries = [
      DropdownMenuEntry<String>(
        value: l10n.genreRomance,
        label: l10n.genreRomance,
      ),
      DropdownMenuEntry<String>(
        value: l10n.genreFantasy,
        label: l10n.genreFantasy,
      ),
      DropdownMenuEntry<String>(
        value: l10n.genreSuspense,
        label: l10n.genreSuspense,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.nextMeeting,
          style: text.headingH3.copyWith(
            color: colors.textBrand,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(spacing.s24),
        child: BlocBuilder<DropdownPreviewCubit, DropdownPreviewState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dropdown',
                  style: text.headingH2.copyWith(
                    color: colors.textDefault,
                  ),
                ),
                SizedBox(height: spacing.s8),
                Text(
                  'Teste do componente',
                  style: text.bodyDefault.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                SizedBox(height: spacing.s24),
                AppDropdown<String>(
                  label: 'Gênero',
                  initialSelection: state.selectedValue,
                  items: genreEntries,
                  onSelected: (value) {
                    if (value == null) {
                      return;
                    }

                    context
                        .read<DropdownPreviewCubit>()
                        .selectValue(value);
                  },
                ),
                SizedBox(height: spacing.s32),
                AppDropdown<String>(
                  label: 'Desabilitado',
                  initialSelection: l10n.genreRomance,
                  items: genreEntries,
                  enabled: false,
                  onSelected: (_) {},
                ),
                SizedBox(height: spacing.s32),
                Text(
                  'Selecionado: ${state.selectedValue ?? '-'}',
                  style: text.bodyDefaultEmphasis.copyWith(
                    color: colors.textDefault,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}