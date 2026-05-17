// lib/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  // Movement commands
  String cmdForward;
  String cmdBackward;
  String cmdLeft;
  String cmdRight;
  String cmdStop;

  // Cutter commands
  String cmdCutterOn;
  String cmdCutterOff;

  // Distance thresholds (in cm)
  int dangerDistance;
  int warningDistance;

  AppSettings({
    this.cmdForward = 'F',
    this.cmdBackward = 'B',
    this.cmdLeft = 'L',
    this.cmdRight = 'R',
    this.cmdStop = 'S',
    this.cmdCutterOn = 'C',
    this.cmdCutterOff = 'X',
    this.dangerDistance = 20,
    this.warningDistance = 50,
  });
}

class SettingsService {
  static const _kForward = 'cmd_forward';
  static const _kBackward = 'cmd_backward';
  static const _kLeft = 'cmd_left';
  static const _kRight = 'cmd_right';
  static const _kStop = 'cmd_stop';
  static const _kCutterOn = 'cmd_cutter_on';
  static const _kCutterOff = 'cmd_cutter_off';
  static const _kDanger = 'threshold_danger';
  static const _kWarning = 'threshold_warning';

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      cmdForward: prefs.getString(_kForward) ?? 'F',
      cmdBackward: prefs.getString(_kBackward) ?? 'B',
      cmdLeft: prefs.getString(_kLeft) ?? 'L',
      cmdRight: prefs.getString(_kRight) ?? 'R',
      cmdStop: prefs.getString(_kStop) ?? 'S',
      cmdCutterOn: prefs.getString(_kCutterOn) ?? 'C',
      cmdCutterOff: prefs.getString(_kCutterOff) ?? 'X',
      dangerDistance: prefs.getInt(_kDanger) ?? 20,
      warningDistance: prefs.getInt(_kWarning) ?? 50,
    );
  }

  static Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kForward, settings.cmdForward);
    await prefs.setString(_kBackward, settings.cmdBackward);
    await prefs.setString(_kLeft, settings.cmdLeft);
    await prefs.setString(_kRight, settings.cmdRight);
    await prefs.setString(_kStop, settings.cmdStop);
    await prefs.setString(_kCutterOn, settings.cmdCutterOn);
    await prefs.setString(_kCutterOff, settings.cmdCutterOff);
    await prefs.setInt(_kDanger, settings.dangerDistance);
    await prefs.setInt(_kWarning, settings.warningDistance);
  }
}
