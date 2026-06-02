import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsState {
  final bool darkMode;
  final bool notificationsEnabled;

  SettingsState({
    this.darkMode = false,
    this.notificationsEnabled = true,
  });

  SettingsState copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final _box = Hive.box('settings');

  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final darkMode = _box.get('darkMode', defaultValue: false);
    final notifications = _box.get('notifications', defaultValue: true);
    state = SettingsState(
      darkMode: darkMode,
      notificationsEnabled: notifications,
    );
  }

  void toggleDarkMode(bool value) {
    state = state.copyWith(darkMode: value);
    _box.put('darkMode', value);
  }

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
    _box.put('notifications', value);
  }
}
