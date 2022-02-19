import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:memogenerator/data/models/template.dart';
import 'package:memogenerator/data/shared_preference_data.dart';
import 'package:rxdart/rxdart.dart';

class TemplatesRepository {
  final updater = PublishSubject<Null>();
  final SharedPreferenceData spData;

  static TemplatesRepository? _instance;

  factory TemplatesRepository.getInstance() => _instance ??=
      TemplatesRepository._internal(SharedPreferenceData.getInstance());

  TemplatesRepository._internal(this.spData);

  Future<bool> addToTemplates(final Template newTemplate) async {
    final templates = await getTemplates();
    final templateIndex =
        templates.indexWhere((template) => template.id == newTemplate.id);
    if (templateIndex == -1) {
      // Добавляем, если нет
      templates.add(newTemplate);
    } else {
      // Меняем, если есть
      templates[templateIndex] = newTemplate;
    }
    return _setTemplates(templates);
  }

  Future<bool> removeFromTemplates(final String id) async {
    final templates = await getTemplates();
    templates.removeWhere((template) => template.id == id);
    return _setTemplates(templates);
  }

  Future<List<Template>> getTemplates() async {
    final rawTemplates = await spData.getTemplates();
    return rawTemplates
        .map(
          (rawTemplate) => Template.fromJson(
              json.decode(rawTemplate) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<Template?> getTemplate(final String id) async {
    final templates = await getTemplates();
    return templates.firstWhereOrNull((template) => template.id == id);
  }

  Stream<List<Template>> observeTemplates() async* {
    yield await getTemplates();
    await for (final _ in updater) {
      yield await getTemplates();
    }
  }

  Future<bool> _setTemplates(final List<Template> templates) async {
    final rawTemplates =
        templates.map((template) => json.encode(template.toJson())).toList();
    return _setRawTemplates(rawTemplates);
  }

  Future<bool> _setRawTemplates(final List<String> rawTemplates) {
    updater.add(null);
    return spData.setTemplates(rawTemplates);
  }
}
