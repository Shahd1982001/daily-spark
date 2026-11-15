import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_spark/state/auth_providers.dart';
import 'package:daily_spark/state/progress_providers.dart';
import 'package:daily_spark/state/settings_providers.dart';

Future<void> _flush() async =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Local auth', () {
    test('validation helpers catch bad input', () {
      expect(validateName(''), isNotNull);
      expect(validateName('A'), isNotNull);
      expect(validateName('Noor'), isNull);
      expect(validateEmail('nope'), isNotNull);
      expect(validateEmail('noor@mail.ly'), isNull);
      expect(validatePassword('12345'), isNotNull);
      expect(validatePassword('123456'), isNull);
    });

    test('signUp validates then stores the account and the name', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(profileInfoProvider);
      await _flush();

      final bad = await c.read(authProvider.notifier).signUp(
          name: 'Noor', email: 'bad', password: '123456', confirmPassword: '123456');
      expect(bad, isNotNull);

      final mismatch = await c.read(authProvider.notifier).signUp(
          name: 'Noor', email: 'noor@mail.ly', password: '123456', confirmPassword: '654321');
      expect(mismatch, isNotNull);

      final ok = await c.read(authProvider.notifier).signUp(
          name: 'Noor', email: 'Noor@Mail.ly', password: '123456', confirmPassword: '123456');
      expect(ok, isNull);
      expect(c.read(authProvider).mode, AuthMode.account);
      expect(c.read(authProvider).email, 'noor@mail.ly'); // normalized
      expect(c.read(userNameProvider), 'Noor'); // identity flows to greeting
    });

    test('signIn checks the stored account; signOut clears the name', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(profileInfoProvider);
      await _flush();

      final none = await c.read(authProvider.notifier)
          .signIn(email: 'x@y.z', password: '123456');
      expect(none, isNotNull); // no account yet

      await c.read(authProvider.notifier).signUp(
          name: 'Noor', email: 'noor@mail.ly', password: '123456', confirmPassword: '123456');
      await c.read(authProvider.notifier).signOut();
      expect(c.read(authProvider).mode, AuthMode.none);
      expect(c.read(userNameProvider), isNull);

      final wrong = await c.read(authProvider.notifier)
          .signIn(email: 'noor@mail.ly', password: '000000');
      expect(wrong, isNotNull);

      final ok = await c.read(authProvider.notifier)
          .signIn(email: 'noor@mail.ly', password: '123456');
      expect(ok, isNull);
      expect(c.read(authProvider).mode, AuthMode.account);
      expect(c.read(userNameProvider), 'Noor'); // restored after login
    });

    test('guest mode enters without identity and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);
      await c1.read(authProvider.notifier).signInAsGuest();
      expect(c1.read(authProvider).signedIn, isTrue);
      expect(c1.read(userNameProvider), isNull);

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(authProvider);
      await _flush();
      expect(c2.read(authProvider).mode, AuthMode.guest); // session survives
    });
  });
}
