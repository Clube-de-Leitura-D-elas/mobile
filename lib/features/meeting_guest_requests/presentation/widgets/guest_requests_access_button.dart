import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/cubit/meeting_guest_requests_cubit.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/cubit/meeting_guest_requests_state.dart';

/// Acesso aos pedidos de participação no detalhe do encontro. Só aparece para
/// a anfitriã e a coordenação; para as outras leitoras, e se a consulta falhar,
/// não ocupa espaço.
class GuestRequestsAccessButton extends StatefulWidget {
  /// Abre a lista; o botão ignora novos toques até ela terminar.
  final Future<void> Function() onPressed;

  const GuestRequestsAccessButton({super.key, required this.onPressed});

  @override
  State<GuestRequestsAccessButton> createState() =>
      _GuestRequestsAccessButtonState();
}

class _GuestRequestsAccessButtonState extends State<GuestRequestsAccessButton> {
  bool _opening = false;

  Future<void> _open() async {
    if (_opening) return;
    _opening = true;
    try {
      await widget.onPressed();
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.requests.length != current.requests.length,
      builder: (context, state) {
        if (state.status != MeetingGuestRequestsStatus.loaded) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.only(top: context.spacing.s16),
          child: AppButton.secondary(
            label: context.l10n.meetingGuestRequestsAccess(
              state.requests.length,
            ),
            size: AppButtonSize.lg,
            onPressed: _open,
          ),
        );
      },
    );
  }
}
