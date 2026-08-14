import 'package:equatable/equatable.dart';

/// Result type represents either a success or failure outcome
sealed class Result<S, F> extends Equatable {
  const Result();

  @override
  List<Object?> get props => [];
}

/// Success variant of Result
final class Success<S, F> extends Result<S, F> {
  const Success(this.data);

  final S data;

  @override
  List<Object?> get props => [data];
}

/// Failure variant of Result
final class Failure<S, F> extends Result<S, F> {
  const Failure(this.failure);

  final F failure;

  @override
  List<Object?> get props => [failure];
}

/// Extension methods for Result
extension ResultExtension<S, F> on Result<S, F> {
  /// Unwrap the success value or throw an exception
  S unwrap() {
    return switch (this) {
      Success<S, F>(:final data) => data,
      Failure<S, F>() => throw Exception('Called unwrap on failure'),
    };
  }

  /// Unwrap the success value or return a placeholder
  S unwrapOr(S placeholder) {
    return switch (this) {
      Success<S, F>(:final data) => data,
      Failure<S, F>() => placeholder,
    };
  }

  /// Pattern match on the result type
  R match<R>(R Function(S data) onSuccess, R Function(F failure) onFailure) {
    return switch (this) {
      Success<S, F>(:final data) => onSuccess(data),
      Failure<S, F>(:final failure) => onFailure(failure),
    };
  }
}
