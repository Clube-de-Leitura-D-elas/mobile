import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/data/datasources/registered_token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferencesRegisteredTokenStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = SharedPreferencesRegisteredTokenStore();
  });

  test('read returns null when nothing was saved', () async {
    expect(await store.read(), isNull);
  });

  test('save then read returns the saved token', () async {
    await store.save('token-a');

    expect(await store.read(), 'token-a');
  });

  test('save replaces the previous token', () async {
    await store.save('token-a');
    await store.save('token-b');

    expect(await store.read(), 'token-b');
  });

  test('clear removes the saved token', () async {
    await store.save('token-a');

    await store.clear();

    expect(await store.read(), isNull);
  });

  test('a new store instance reads what the previous one saved', () async {
    await store.save('token-a');

    expect(await SharedPreferencesRegisteredTokenStore().read(), 'token-a');
  });

  group('when the storage fails', () {
    late SharedPreferencesRegisteredTokenStore failingStore;

    setUp(() {
      failingStore = SharedPreferencesRegisteredTokenStore(
        loadPreferences: () async => throw Exception('storage unavailable'),
      );
    });

    test('read returns null instead of throwing', () async {
      expect(await failingStore.read(), isNull);
    });

    test('save does not throw', () async {
      await expectLater(failingStore.save('token-a'), completes);
    });

    test('clear does not throw', () async {
      await expectLater(failingStore.clear(), completes);
    });
  });
}
