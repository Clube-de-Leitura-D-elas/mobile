import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_state.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';

class ClaimTokenScreen extends StatefulWidget {
  final String userId;

  const ClaimTokenScreen({super.key, required this.userId});

  @override
  State<ClaimTokenScreen> createState() => _ClaimTokenScreenState();
}

class _ClaimTokenScreenState extends State<ClaimTokenScreen> {
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _onConfirm(BuildContext context) {
    final token = _tokenController.text;
    context.read<ClaimTokenCubit>().submitToken(
      claimToken: token,
      userId: widget.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final spacing = context.spacing;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.claimTokenTitle,
          style: text.headingH3.copyWith(color: colors.textBrand),
        ),
      ),
      body: BlocListener<ClaimTokenCubit, ClaimTokenState>(
        listener: (context, state) {
          if (state is ClaimTokenFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colors.actionDanger,
              ),
            );
            return;
          }

          if (state is ClaimTokenSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.claimTokenSuccessMessage),
                backgroundColor: colors.actionPrimary,
              ),
            );
            context.read<SessionCubit>().checkUserProfile(widget.userId);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(spacing.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.claimTokenInputHeader,
                style: text.headingH2.copyWith(color: colors.textDefault),
                textAlign: TextAlign.center,
              ),
              const Gap16(),
              Text(
                l10n.claimTokenInputDescription,
                style: text.bodyDefault.copyWith(color: colors.textMuted),
                textAlign: TextAlign.center,
              ),
              const Gap24(),
              TextField(
                controller: _tokenController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.claimTokenFieldLabel,
                  hintText: l10n.claimTokenFieldHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const Gap24(),
              BlocBuilder<ClaimTokenCubit, ClaimTokenState>(
                builder: (context, state) {
                  final isLoading = state is ClaimTokenLoading;
                  return AppButton.primary(
                    label: context.l10n.confirm,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : () => _onConfirm(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
