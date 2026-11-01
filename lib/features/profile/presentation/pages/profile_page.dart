import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';

import 'profile_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDefault,
      body: SafeArea(
        // O perfil já vem do get-user-profile carregado pela sessão no login.
        // Só redesenha com sessão autenticada: no logout o LoadingSession
        // apagaria o nome antes do redirect.
        child: BlocBuilder<SessionCubit, SessionState>(
          buildWhen: (_, state) => state is AuthenticatedSession,
          builder: (context, state) => ProfileScreen(
            profile: state is AuthenticatedSession ? state.profile : null,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: QuickAccessItem.profile.index,
        onItemSelected: (index) => context.goToQuickAccessTab(
          index,
          currentIndex: QuickAccessItem.profile.index,
        ),
      ),
    );
  }
}
