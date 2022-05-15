import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceData {
  SharedPreferenceData._internal();

  factory SharedPreferenceData.getInstance() =>
      _instance ??= SharedPreferenceData._internal();

  static SharedPreferenceData? _instance;
  static const memeKey = 'meme_key';
  static const templateKey = 'template_key';

  Future<bool> setMemes(final List<String> memes) async =>
      setItems(memeKey, memes);

  Future<List<String>> getMemes() async => getItems(memeKey);

  Future<bool> setTemplates(final List<String> templates) async =>
      setItems(templateKey, templates);

  Future<List<String>> getTemplates() async => getItems(templateKey);

  Future<bool> setItems(final String key, final List<String> items) async {
    final sp = await SharedPreferences.getInstance();
    final result = sp.setStringList(key, items);

    return result;
  }

  Future<List<String>> getItems(final String key) async {
    final sp = await SharedPreferences.getInstance();

    return sp.getStringList(key) ?? [];
  }
}
