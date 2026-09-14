import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class PasswordValidationState extends Equatable {
  final bool hasMinLength;
  final bool hasUpperCase;
  final bool hasLowerCase;
  final bool hasNumber;
  final bool passwordsMatch;
  final bool isConfirmEmpty;

  const PasswordValidationState({
    this.hasMinLength = false,
    this.hasUpperCase = false,
    this.hasLowerCase = false,
    this.hasNumber = false,
    this.passwordsMatch = false,
    this.isConfirmEmpty = true,
  });

  bool get isValid =>
      hasMinLength &&
      hasUpperCase &&
      hasLowerCase &&
      hasNumber &&
      passwordsMatch &&
      !isConfirmEmpty;

  PasswordValidationState copyWith({
    bool? hasMinLength,
    bool? hasUpperCase,
    bool? hasLowerCase,
    bool? hasNumber,
    bool? passwordsMatch,
    bool? isConfirmEmpty,
  }) {
    return PasswordValidationState(
      hasMinLength: hasMinLength ?? this.hasMinLength,
      hasUpperCase: hasUpperCase ?? this.hasUpperCase,
      hasLowerCase: hasLowerCase ?? this.hasLowerCase,
      hasNumber: hasNumber ?? this.hasNumber,
      passwordsMatch: passwordsMatch ?? this.passwordsMatch,
      isConfirmEmpty: isConfirmEmpty ?? this.isConfirmEmpty,
    );
  }

  @override
  List<Object?> get props => [
        hasMinLength,
        hasUpperCase,
        hasLowerCase,
        hasNumber,
        passwordsMatch,
        isConfirmEmpty,
      ];
}

class PasswordValidationCubit extends Cubit<PasswordValidationState> {
  PasswordValidationCubit() : super(const PasswordValidationState());

  void validate(String password, String confirmPassword) {
    emit(state.copyWith(
      hasMinLength: password.length >= 8,
      hasUpperCase: password.contains(RegExp(r'[A-Z]')),
      hasLowerCase: password.contains(RegExp(r'[a-z]')),
      hasNumber: password.contains(RegExp(r'[0-9]')),
      passwordsMatch: password == confirmPassword,
      isConfirmEmpty: confirmPassword.isEmpty,
    ));
  }
}
