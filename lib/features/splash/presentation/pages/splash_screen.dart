import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/user_failure_message.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Tela de abertura: logo e indicador de carregamento enquanto a sessão é
/// verificada. Se o perfil não carrega, mostra o motivo com "Tentar novamente"
/// e "Sair".
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final logoLabel = l10n?.appLogoSemanticLabel ?? 'Logo do aplicativo';

    return Scaffold(
      backgroundColor: colors.bgDefault,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      image: true,
                      label: logoLabel,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 160.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Gap24(),
                    BlocBuilder<SessionCubit, SessionState>(
                      builder: (context, state) {
                        if (state is SessionProfileUnavailable &&
                            l10n != null) {
                          final cubit = context.read<SessionCubit>();
                          final reason = userFailureMessage(
                            l10n,
                            state.failure,
                            fallback: l10n.genericError,
                          );
                          return AppErrorState(
                            message: l10n.sessionProfileLoadError(reason),
                            onRetry: userFailureIsRetryable(state.failure)
                                ? cubit.retryProfile
                                : null,
                            secondaryLabel: l10n.logoutTooltip,
                            onSecondary: cubit.logOut,
                          );
                        }
                        return CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.actionPrimary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
