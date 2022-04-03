import 'dart:convert';

import 'package:memegenerator/data/models/template.dart';
import 'package:memegenerator/data/repositories/list_with_ids_reactive_repository.dart';
import 'package:memegenerator/data/shared_preference_data.dart';

class TemplatesRepository extends ListWithIdsReactiveRepository<Template> {
  factory TemplatesRepository.getInstance() => _instance ??=
      TemplatesRepository._internal(SharedPreferenceData.getInstance());

  TemplatesRepository._internal(this.spData);

  static TemplatesRepository? _instance;
  final SharedPreferenceData spData;

  @override
  Template convertFromString(String rawItem) =>
      Template.fromJson(json.decode(rawItem) as Map<String, dynamic>);

  @override
  String convertToString(Template item) => json.encode(item.toJson());

  @override
  String getId(Template item) => item.id;

  @override
  Future<List<String>> getRawData() => spData.getTemplates();

  @override
  Future<bool> saveRawData(List<String> items) => spData.setTemplates(items);
}
