import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/widgets/google_sign_in_button.dart';

/// Login screen matching Figma spec (node-id: 771-1625) for Clube de Leitura D'Elas.
///
/// Supports email + password authentication with Supabase and Google OAuth.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onForgotPasswordPressed,
    this.onCreateAccountPressed,
  });

  final VoidCallback? onForgotPasswordPressed;
  final VoidCallback? onCreateAccountPressed;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitEmailPassword(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    context.read<SessionCubit>().authenticateWithEmail(
          email: email,
          password: password,
        );
  }

  void _submitGoogleAuth(BuildContext context) {
    context.read<SessionCubit>().authenticate();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.text;
    final spacing = context.spacing;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgDefault,
      body: SafeArea(
        child: BlocBuilder<SessionCubit, SessionState>(
          builder: (context, state) {
            final isLoading = state is LoadingSession;

            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Gap(104),
                        // Title & Form Block (#879:1799)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.s16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.loginTitle,
                                textAlign: TextAlign.center,
                                style: typography.headingH1.copyWith(
                                  color: colors.textDefault,
                                ),
                              ),
                              const Gap32(),
                              AppTextField(
                                label: l10n.emailLabel,
                                hintText: l10n.emailHint,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                enabled: !isLoading,
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  if (email.isEmpty) {
                                    return l10n.emailRequiredError;
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(email)) {
                                    return l10n.emailInvalidError;
                                  }
                                  return null;
                                },
                              ),
                              const Gap16(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  AppTextField(
                                    label: l10n.passwordLabel,
                                    controller: _passwordController,
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _submitEmailPassword(context),
                                    enabled: !isLoading,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.passwordRequiredError;
                                      }
                                      return null;
                                    },
                                  ),
                                  const Gap4(),
                                  GestureDetector(
                                    onTap: isLoading ? null : widget.onForgotPasswordPressed,
                                    child: Text(
                                      l10n.forgotPasswordLink,
                                      style: typography.labelTag.copyWith(
                                        color: colors.textBrand,
                                        height: 24.0 / 12.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Flexible space pushing actions block down towards bottom
                        const Spacer(),

                        // Actions Block (#879:1797) - 35px horizontal padding (320px width on 390px frame)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppButton.primary(
                                label: l10n.continueAction,
                                isLoading: isLoading,
                                onPressed: isLoading ? null : () => _submitEmailPassword(context),
                              ),
                              const Gap16(),
                              GoogleSignInButton(
                                isLoading: isLoading,
                                onPressed: isLoading ? null : () => _submitGoogleAuth(context),
                              ),
                              const Gap16(),
                              Center(
                                child: GestureDetector(
                                  onTap: isLoading ? null : widget.onCreateAccountPressed,
                                  child: Text(
                                    l10n.createAccountLink,
                                    textAlign: TextAlign.center,
                                    style: typography.bodySmallEmphasis.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colors.textBrand,
                                      height: 24.0 / 14.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(48),
                      ],
                    ),
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
