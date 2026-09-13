import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/presentation/cubit/password_validation_cubit.dart';

void main() {
  late PasswordValidationCubit cubit;

  setUp(() {
    cubit = PasswordValidationCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('PasswordValidationCubit', () {
    test('initial state has default false values and isConfirmEmpty true', () {
      expect(cubit.state, equals(const PasswordValidationState()));
      expect(cubit.state.isValid, isFalse);
    });

    test('validates password with all requirements met', () {
      cubit.validate('Pass1234', 'Pass1234');

      expect(cubit.state.hasMinLength, isTrue);
      expect(cubit.state.hasUpperCase, isTrue);
      expect(cubit.state.hasLowerCase, isTrue);
      expect(cubit.state.hasNumber, isTrue);
      expect(cubit.state.passwordsMatch, isTrue);
      expect(cubit.state.isConfirmEmpty, isFalse);
      expect(cubit.state.isValid, isTrue);
    });

    test('validates password failing min length', () {
      cubit.validate('P1a', 'P1a');

      expect(cubit.state.hasMinLength, isFalse);
      expect(cubit.state.hasUpperCase, isTrue);
      expect(cubit.state.hasLowerCase, isTrue);
      expect(cubit.state.hasNumber, isTrue);
      expect(cubit.state.isValid, isFalse);
    });

    test('validates password failing uppercase letter', () {
      cubit.validate('pass1234', 'pass1234');

      expect(cubit.state.hasMinLength, isTrue);
      expect(cubit.state.hasUpperCase, isFalse);
      expect(cubit.state.isValid, isFalse);
    });

    test('validates password failing lowercase letter', () {
      cubit.validate('PASS1234', 'PASS1234');

      expect(cubit.state.hasMinLength, isTrue);
      expect(cubit.state.hasLowerCase, isFalse);
      expect(cubit.state.isValid, isFalse);
    });

    test('validates password failing number', () {
      cubit.validate('Password', 'Password');

      expect(cubit.state.hasMinLength, isTrue);
      expect(cubit.state.hasNumber, isFalse);
      expect(cubit.state.isValid, isFalse);
    });

    test('validates password mismatch when confirmPassword differs', () {
      cubit.validate('Pass1234', 'Pass1235');

      expect(cubit.state.hasMinLength, isTrue);
      expect(cubit.state.passwordsMatch, isFalse);
      expect(cubit.state.isValid, isFalse);
    });

    test('copyWith copies state with updated values', () {
      const state = PasswordValidationState();
      final updated = state.copyWith(
        hasMinLength: true,
        hasUpperCase: true,
        hasLowerCase: true,
        hasNumber: true,
        passwordsMatch: true,
        isConfirmEmpty: false,
      );

      expect(updated.isValid, isTrue);
      expect(updated.props.length, equals(6));
    });
  });
}
