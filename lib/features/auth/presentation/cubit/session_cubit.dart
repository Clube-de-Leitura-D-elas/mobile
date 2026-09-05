import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/usecases/get_user_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_with_email_use_case.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionCubit extends Cubit<SessionState> {
  final UserSignInUseCase userSignInUseCase;
  final UserSignInWithEmailUseCase userSignInWithEmailUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final SupabaseService supabaseService;

  StreamSubscription<AuthState>? _authStateSubscription;

  SessionCubit({
    required this.userSignInUseCase,
    required this.userSignInWithEmailUseCase,
    required this.getUserProfileUseCase,
    required this.supabaseService,
  }) : super(const GuestSession()) {
    _listenToAuthState();
    _checkCurrentSession();
  }

  void _checkCurrentSession() {
    final user = supabaseService.currentUser;
    debugPrint('[SessionCubit] Initial currentUser check: ${user?.id}');
    if (user == null) return;

    checkUserProfile(user.id);
  }

  void _listenToAuthState() {
    _authStateSubscription = supabaseService.authStateChanges.listen((data) {
      debugPrint('[SessionCubit] AuthState change event: ${data.event}, user: ${data.session?.user.id}');

      if (data.event == AuthChangeEvent.signedOut) {
        debugPrint('[SessionCubit] User signed out -> emitting GuestSession');
        emit(const GuestSession());
        return;
      }

      final isSignInEvent = data.event == AuthChangeEvent.signedIn ||
          data.event == AuthChangeEvent.initialSession;
      final session = data.session;

      if (!isSignInEvent || session == null) return;

      checkUserProfile(session.user.id);
    });
  }

  Future<void> authenticate() async {
    debugPrint('[SessionCubit] Triggering Google Sign-In authentication');
    emit(const LoadingSession());

    final result = await userSignInUseCase.call();

    if (result case Failure(:final failure)) {
      debugPrint('[SessionCubit] Sign-In failed: ${failure.message}');
      emit(SessionError(message: failure.message));
      emit(const GuestSession());
      return;
    }

    final userEntity = result.unwrap();
    final currentUser = supabaseService.currentUser;
    debugPrint('[SessionCubit] Google Sign-In success for user: ${currentUser?.id}');
    if (currentUser == null) {
      emit(const GuestSession());
      return;
    }

    await checkUserProfile(currentUser.id, userEntity);
  }

  Future<void> authenticateWithEmail({
    required String email,
    required String password,
  }) async {
    debugPrint('[SessionCubit] Triggering Email+Password authentication for email: $email');
    emit(const LoadingSession());

    final result = await userSignInWithEmailUseCase.call(
      email: email,
      password: password,
    );

    if (result case Failure(:final failure)) {
      debugPrint('[SessionCubit] Email Sign-In failed: ${failure.message}');
      emit(SessionError(message: failure.message));
      emit(const GuestSession());
      return;
    }

    final userEntity = result.unwrap();
    final currentUser = supabaseService.currentUser;
    debugPrint('[SessionCubit] Email Sign-In success for user: ${currentUser?.id}');
    if (currentUser == null) {
      emit(const GuestSession());
      return;
    }

    await checkUserProfile(currentUser.id, userEntity);
  }

  Future<void> checkUserProfile(String userId, [UserEntity? userEntity]) async {
    debugPrint('[SessionCubit] Checking user profile for userId: $userId');
    emit(const LoadingSession());

    final profileResult = await getUserProfileUseCase(userId);

    if (profileResult case Failure(:final failure)) {
      debugPrint('[SessionCubit] getUserProfile failure: ${failure.message}');
      emit(NeedsClaimSession(userId: userId, user: userEntity));
      return;
    }

    final data = profileResult.unwrap();
    if (data == null) {
      debugPrint('[SessionCubit] Profile is null -> emitting NeedsClaimSession for userId: $userId');
      emit(NeedsClaimSession(userId: userId, user: userEntity));
      return;
    }

    final user = userEntity ??
        UserEntity(
          name: data.name,
          mail: data.email,
          birthday: data.birthday,
          phoneNumber: data.phoneNumber,
          instagramUser: data.instagram,
          educationDegree: data.educationDegree,
          jobPosition: data.jobPosition,
          cityZone: (id: '', name: '', acronym: ''),
        );

    debugPrint('[SessionCubit] Profile found! Emitting AuthenticatedSession for ${user.name}');
    emit(AuthenticatedSession(user: user, profile: data));
  }

  Future<void> logOut() async {
    debugPrint('[SessionCubit] Logging out user and clearing Supabase session');
    emit(const LoadingSession());
    await supabaseService.signOut();
    emit(const GuestSession());
  }

  void reset() {
    logOut();
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
