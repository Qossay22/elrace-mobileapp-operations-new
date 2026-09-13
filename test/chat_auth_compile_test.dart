import 'package:el_race/chat/models/chat_user_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chat auth/session files compile after log cleanup', () {
    final session = ChatUserSession(
      backendJwt: 'backend-token',
      odooUserId: 42,
      name: 'User',
      roleId: 7,
      companyId: 1,
      firebaseUid: 'odoo_42',
      firebaseCustomToken: 'header.payload.signature',
    );

    final disabled = ChatSetupResult.disabled('missing token');

    expect(session.isChatAvailable, isTrue);
    expect(session.toString(), isNot(contains('odoo_42')));
    expect(disabled.success, isTrue);
    expect(disabled.chatEnabled, isFalse);
  });
}
