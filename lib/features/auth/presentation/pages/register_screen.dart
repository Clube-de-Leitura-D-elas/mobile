import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/password_validation_cubit.dart';
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
  final _confirmPasswordController = TextEditingController();
  late PasswordValidationCubit _passwordCubit;

  @override
  void initState() {
    super.initState();
    _passwordCubit = PasswordValidationCubit();
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    _passwordCubit.validate(
      _passwordController.text,
      _confirmPasswordController.text,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordCubit.close();
    super.dispose();
  }

  void _submitEmailPassword(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    
    if (!_passwordCubit.state.isValid) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    context.read<SessionCubit>().signUpWithEmail(
      email: email,
      password: password,
    );
  }
  
  Widget _buildCheckItem(bool isValid, String text) {
    final colors = context.colors;
    final typography = context.text;
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? colors.feedbackSuccess : colors.feedbackError,
          size: 16,
        ),
        const Gap4(),
        Text(
          text,
          style: typography.bodySmall.copyWith(
            color: isValid ? colors.feedbackSuccess : colors.feedbackError,
          ),
        ),
      ],
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
        child: BlocConsumer<SessionCubit, SessionState>(
          listener: (context, state) {
            if (state is SessionError) {
              if (state.message.toLowerCase().contains('email not confirmed')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, confirme seu e-mail antes de logar.'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
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
                        const Gap(64),
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
                                textInputAction: TextInputAction.next,
                                enabled: !isLoading,
                              ),
                              const Gap16(),
                              AppTextField(
                                label: 'Confirmar Senha',
                                controller: _confirmPasswordController,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) =>
                                    _submitEmailPassword(context),
                                enabled: !isLoading,
                              ),
                              const Gap16(),
                              BlocBuilder<PasswordValidationCubit, PasswordValidationState>(
                                bloc: _passwordCubit,
                                builder: (context, passState) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildCheckItem(passState.hasMinLength, 'Pelo menos 8 caracteres'),
                                      const Gap4(),
                                      _buildCheckItem(passState.hasUpperCase, 'Pelo menos 1 letra maiúscula'),
                                      const Gap4(),
                                      _buildCheckItem(passState.hasLowerCase, 'Pelo menos 1 letra minúscula'),
                                      const Gap4(),
                                      _buildCheckItem(passState.hasNumber, 'Pelo menos 1 número'),
                                      const Gap4(),
                                      _buildCheckItem(passState.passwordsMatch && !passState.isConfirmEmpty, 'Senhas conferem'),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Flexible space pushing actions block down towards bottom
                        const Spacer(),

                        // Actions Block
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              BlocBuilder<PasswordValidationCubit, PasswordValidationState>(
                                bloc: _passwordCubit,
                                builder: (context, passState) {
                                  return AppButton.primary(
                                    label: 'Cadastrar',
                                    isLoading: isLoading,
                                    onPressed: isLoading || !passState.isValid
                                        ? null
                                        : () => _submitEmailPassword(context),
                                  );
                                }
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
