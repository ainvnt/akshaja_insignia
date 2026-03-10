class AutoRefreshMemoryService {
  static bool enabled = false;
  static Duration interval = const Duration(hours: 1);

  static void save({required bool isEnabled, required Duration every}) {
    enabled = isEnabled;
    interval = every;
  }
}
