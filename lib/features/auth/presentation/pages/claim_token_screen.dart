import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/usecases/claim_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/get_user_profile_use_case.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_state.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';

class ClaimTokenScreen extends StatelessWidget {
  final String userId;

  const ClaimTokenScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClaimTokenCubit(
        claimProfileUseCase: serviceLocator<ClaimProfileUseCase>(),
        getUserProfileUseCase: serviceLocator<GetUserProfileUseCase>(),
      ),
      child: ClaimTokenView(userId: userId),
    );
  }
}

class ClaimTokenView extends StatefulWidget {
  final String userId;

  const ClaimTokenView({super.key, required this.userId});

  @override
  State<ClaimTokenView> createState() => _ClaimTokenViewState();
}

class _ClaimTokenViewState extends State<ClaimTokenView> {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vincular Perfil',
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
                content: const Text('Perfil vinculado com sucesso!'),
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
                'Informe o seu Token de Acesso',
                style: text.headingH2.copyWith(color: colors.textDefault),
                textAlign: TextAlign.center,
              ),
              const Gap16(),
              Text(
                'Digite o token fornecido após a aprovação para vincular sua conta.',
                style: text.bodyDefault.copyWith(color: colors.textMuted),
                textAlign: TextAlign.center,
              ),
              const Gap24(),
              TextField(
                controller: _tokenController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Claim Token',
                  hintText: 'Ex: 1A2B3C4D',
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
                    label: 'Confirmar',
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
