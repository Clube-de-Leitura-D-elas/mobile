import 'package:equatable/equatable.dart';

class HttpFailure extends Equatable {
  final String message;

  const HttpFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Generic HTTP Failure
class UnknownFailure extends HttpFailure {
  const UnknownFailure(super.message);
}

///  HTTP Status Code 400
class BadRequestFailure extends HttpFailure {
  const BadRequestFailure(super.message);
}

///  HTTP Status Code 401
class UnauthorizedFailure extends HttpFailure {
  const UnauthorizedFailure(super.message);
}

///  HTTP Status Code 403
class ForbiddenFailure extends HttpFailure {
  const ForbiddenFailure(super.message);
}

///  HTTP Status Code 404
class NotFoundFailure extends HttpFailure {
  const NotFoundFailure(super.message);
}

///  HTTP Status Code 405
class MethodNotAllowedFailure extends HttpFailure {
  const MethodNotAllowedFailure(super.message);
}

///  HTTP Status Code 406
class NotAcceptableFailure extends HttpFailure {
  const NotAcceptableFailure(super.message);
}

///  HTTP Status Code 408
class RequestTimeoutFailure extends HttpFailure {
  const RequestTimeoutFailure(super.message);
}

///  HTTP Status Code 409
class ConflictFailure extends HttpFailure {
  const ConflictFailure(super.message);
}

///  HTTP Status Code 429
class TooManyRequestsFailure extends HttpFailure {
  const TooManyRequestsFailure(super.message);
}

///  HTTP Status Code 500
class InternalServerErrorFailure extends HttpFailure {
  const InternalServerErrorFailure(super.message);
}

///  HTTP Status Code 502
class BadGatewayFailure extends HttpFailure {
  const BadGatewayFailure(super.message);
}

///  HTTP Status Code 503
class ServiceUnavailableFailure extends HttpFailure {
  const ServiceUnavailableFailure(super.message);
}

///  HTTP Status Code 504
class GatewayTimeoutFailure extends HttpFailure {
  const GatewayTimeoutFailure(super.message);
}

HttpFailure httpFailureFromStatusCode(int statusCode, String message) {
  return switch (statusCode) {
    400 => BadRequestFailure(message),
    401 => UnauthorizedFailure(message),
    403 => ForbiddenFailure(message),
    404 => NotFoundFailure(message),
    405 => MethodNotAllowedFailure(message),
    406 => NotAcceptableFailure(message),
    408 => RequestTimeoutFailure(message),
    409 => ConflictFailure(message),
    429 => TooManyRequestsFailure(message),
    500 => InternalServerErrorFailure(message),
    502 => BadGatewayFailure(message),
    503 => ServiceUnavailableFailure(message),
    504 => GatewayTimeoutFailure(message),
    _ => UnknownFailure(message),
  };
}
