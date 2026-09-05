import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_service_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late SupabaseServiceImpl supabaseService;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    supabaseService = SupabaseServiceImpl(mockSupabaseClient);
  });

  test('SupabaseServiceImpl instantiates correctly', () {
    expect(supabaseService, isNotNull);
  });
}
