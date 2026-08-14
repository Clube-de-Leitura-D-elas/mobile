import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/http/http_response.dart';

void main() {
  group('HttpResponse', () {
    test('props contains statusCode and data', () {
      const response1 = HttpResponse(statusCode: 200, data: {'key': 'value'});
      const response2 = HttpResponse(statusCode: 200, data: {'key': 'value'});
      const response3 = HttpResponse(statusCode: 404, data: 'Not found');

      expect(response1.statusCode, equals(200));
      expect(response1.data, equals({'key': 'value'}));
      expect(response1.props, equals([200, {'key': 'value'}]));
      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });
  });
}
