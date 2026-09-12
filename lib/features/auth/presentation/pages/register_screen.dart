import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.onLoginPressed,
  });

  final VoidCallback? onLoginPressed;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

    context.read<SessionCubit>().signUpWithEmail(
      email: email,
      password: password,
    );
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
                        // Title & Form Block
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.s16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Criar Conta',
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
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(email)) {
                                    return l10n.emailInvalidError;
                                  }
                                  return null;
                                },
                              ),
                              const Gap16(),
                              AppTextField(
                                label: l10n.passwordLabel,
                                controller: _passwordController,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) =>
                                    _submitEmailPassword(context),
                                enabled: !isLoading,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return l10n.passwordRequiredError;
                                  }
                                  if (value.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        // Flexible space pushing actions block down towards bottom
                        const Spacer(),

                        // Actions Block
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppButton.primary(
                                label: 'Cadastrar',
                                isLoading: isLoading,
                                onPressed: isLoading
                                    ? null
                                    : () => _submitEmailPassword(context),
                              ),
                              const Gap16(),
                              Center(
                                child: GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : widget.onLoginPressed,
                                  child: Text(
                                    'Já tenho uma conta',
                                    textAlign: TextAlign.center,
                                    style: typography.bodySmallEmphasis
                                        .copyWith(
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
