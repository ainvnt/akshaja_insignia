class AutoRefreshMemoryService {
  static bool enabled = true;
  static Duration interval = const Duration(minutes: 5);

  static void save({required bool isEnabled, required Duration every}) {
    enabled = isEnabled;
    interval = every;
  }
}
