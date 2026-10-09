import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_collection/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthService.instance.clearForTesting();
  });

  test('registers and logs in a new user', () async {
    final registered = await AuthService.instance.register(
      username: 'alice',
      email: 'alice@example.com',
      password: 'secret123',
    );

    expect(registered, isTrue);

    final loggedIn = await AuthService.instance.login(
      usernameOrEmail: 'alice',
      password: 'secret123',
    );

    expect(loggedIn, isTrue);
    expect(AuthService.instance.currentUser?.username, 'alice');
  });

  test('resets a password for an existing user', () async {
    await AuthService.instance.register(
      username: 'bob',
      email: 'bob@example.com',
      password: 'oldpass',
    );

    final reset = await AuthService.instance.forgotPassword(
      usernameOrEmail: 'bob',
      newPassword: 'newpass123',
    );

    expect(reset, isTrue);

    final loggedIn = await AuthService.instance.login(
      usernameOrEmail: 'bob',
      password: 'newpass123',
    );

    expect(loggedIn, isTrue);
  });
}
