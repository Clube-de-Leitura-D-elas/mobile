import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.nextMeeting,
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
                const Gap8(),
                Text(
                  'Teste do componente',
                  style: text.bodyDefault.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                const Gap24(),
                AppDropdown<String>(
                  label: 'Status',
                  items: const [
                    'Todos',
                    'Ativos',
                    'Inativos',
                  ],
                  value: state.selectedValue,
                  onChanged: (value) {
                    context
                        .read<DropdownPreviewCubit>()
                        .selectValue(value);
                  },
                ),
                const Gap32(),
                AppDropdown<String>(
                  label: 'Desabilitado',
                  items: const [
                    'Opção 1',
                    'Opção 2',
                  ],
                  value: 'Opção 1',
                  enabled: false,
                  onChanged: (_) {},
                ),
                const Gap32(),
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