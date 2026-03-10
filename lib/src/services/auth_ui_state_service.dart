class AuthUiStateService {
  static bool _showLoginSuccessOnHome = false;

  static void markLoginSuccessForHome() {
    _showLoginSuccessOnHome = true;
  }

  static bool consumeLoginSuccessForHome() {
    final value = _showLoginSuccessOnHome;
    _showLoginSuccessOnHome = false;
    return value;
  }
}
