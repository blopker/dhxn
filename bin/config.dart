import 'dart:io';
import 'dart:math';

String _staticBase = () {
  var random = 'RANDOM';
  if (Env.isProduction) {
    random = '${Random().nextInt(1000000)}';
  }
  return '/static-$random';
}();

class Env {
  static String env(key, defaultValue) =>
      Platform.environment[key] ?? defaultValue;
  static String get port => env('PORT', 8080);
  static bool get isDebug => env('DEBUG', 'false') == 'true';
  static bool get isProduction => !isDebug;
  static String get staticBase => _staticBase;
}
