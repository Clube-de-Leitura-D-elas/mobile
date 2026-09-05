import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';

class HomeScreen extends StatelessWidget {
  final UserEntity user;
  final UserProfileEntity? profile;

  const HomeScreen({
    super.key,
    required this.user,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final spacing = context.spacing;

    final name = profile?.name.isNotEmpty == true ? profile!.name : user.name;
    final email = profile?.email.isNotEmpty == true ? profile!.email : user.mail;
    final address = profile?.address;
    final phone = profile?.phoneNumber.isNotEmpty == true ? profile!.phoneNumber : user.phoneNumber;
    final birthday = profile?.birthday.isNotEmpty == true ? profile!.birthday : user.birthday;
    final instagram = profile?.instagram.isNotEmpty == true ? profile!.instagram : user.instagramUser;
    final education = profile?.educationDegree.isNotEmpty == true ? profile!.educationDegree : user.educationDegree;
    final job = profile?.jobPosition.isNotEmpty == true ? profile!.jobPosition : user.jobPosition;
    final userId = profile?.userId ?? '';
    final isActive = profile?.isActive ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.appTitle,
          style: text.headingH3.copyWith(color: colors.textBrand),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<SessionCubit>().logOut(),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(spacing.s24),
              decoration: BoxDecoration(
                color: colors.surfaceSunken,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: colors.borderDefault),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: colors.surfaceBrandSoft,
                    child: Icon(
                      Icons.person_outline,
                      size: 40,
                      color: colors.actionPrimary,
                    ),
                  ),
                  const Gap16(),
                  Text(
                    name.isNotEmpty ? name : 'Usuária',
                    style: text.headingH2.copyWith(color: colors.textDefault),
                    textAlign: TextAlign.center,
                  ),
                  const Gap4(),
                  Text(
                    email,
                    style: text.bodyDefault.copyWith(color: colors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const Gap12(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? colors.feedbackSuccessLight : colors.surfaceBrandSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: isActive ? colors.feedbackSuccessDark : colors.actionPrimary,
                        ),
                        const Gap4(),
                        Text(
                          'Perfil Vinculado & Ativo',
                          style: text.labelTag.copyWith(
                            color: isActive ? colors.feedbackSuccessDark : colors.actionPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap24(),
            Text(
              'Dados do Perfil Cadastrado',
              style: text.headingH3.copyWith(color: colors.textDefault),
            ),
            const Gap16(),
            _ProfileDetailTile(
              icon: Icons.badge_outlined,
              label: 'Nome Completo',
              value: name,
            ),
            _ProfileDetailTile(
              icon: Icons.email_outlined,
              label: 'E-mail',
              value: email,
            ),
            if (phone.isNotEmpty)
              _ProfileDetailTile(
                icon: Icons.phone_outlined,
                label: 'Telefone',
                value: phone,
              ),
            if (address != null && address.isNotEmpty)
              _ProfileDetailTile(
                icon: Icons.location_on_outlined,
                label: 'Endereço',
                value: address,
              ),
            if (birthday.isNotEmpty)
              _ProfileDetailTile(
                icon: Icons.cake_outlined,
                label: 'Data de Nascimento',
                value: birthday,
              ),
            if (instagram.isNotEmpty)
              _ProfileDetailTile(
                icon: Icons.camera_alt_outlined,
                label: 'Instagram',
                value: instagram,
              ),
            if (education.isNotEmpty)
              _ProfileDetailTile(
                icon: Icons.school_outlined,
                label: 'Escolaridade',
                value: education,
              ),
            if (job.isNotEmpty)
              _ProfileDetailTile(
                icon: Icons.work_outline,
                label: 'Cargo / Profissão',
                value: job,
              ),
            if (userId.isNotEmpty)
              _ProfileDetailTile(
                icon: Icons.fingerprint,
                label: 'ID Auth (Supabase User ID)',
                value: userId,
              ),
            const Gap32(),
            AppButton.secondary(
              label: 'Sair da Conta',
              onPressed: () => context.read<SessionCubit>().logOut(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileDetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: colors.bgSubtle,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: colors.borderDefault),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.actionPrimary, size: 24),
            const Gap12(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: text.caption.copyWith(color: colors.textMuted),
                  ),
                  const Gap2(),
                  Text(
                    value.isNotEmpty ? value : 'Não informado',
                    style: text.bodyDefaultEmphasis.copyWith(color: colors.textDefault),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
