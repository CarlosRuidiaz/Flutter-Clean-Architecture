import 'package:f_clean_template/core/i_local_preferences.dart';

/// Preferencias locales en un mapa en memoria.
///
/// Las pruebas de integracion no dependen del almacenamiento del dispositivo:
/// cada arranque empieza con las preferencias vacias.
class FakeLocalPreferences implements ILocalPreferences {
  final Map<String, Object> _valores = <String, Object>{};

  @override
  Future<void> clear() async => _valores.clear();

  @override
  Future<bool?> getBool(String key) async => _valores[key] as bool?;

  @override
  Future<double?> getDouble(String key) async => _valores[key] as double?;

  @override
  Future<int?> getInt(String key) async => _valores[key] as int?;

  @override
  Future<String?> getString(String key) async => _valores[key] as String?;

  @override
  Future<List<String>?> getStringList(String key) async =>
      (_valores[key] as List<String>?)?.toList();

  @override
  Future<void> remove(String key) async => _valores.remove(key);

  @override
  Future<void> setBool(String key, bool value) async => _valores[key] = value;

  @override
  Future<void> setDouble(String key, double value) async =>
      _valores[key] = value;

  @override
  Future<void> setInt(String key, int value) async => _valores[key] = value;

  @override
  Future<void> setString(String key, String value) async =>
      _valores[key] = value;

  @override
  Future<void> setStringList(String key, List<String> value) async =>
      _valores[key] = value.toList();
}
