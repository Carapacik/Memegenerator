import 'dart:convert';

import 'package:memegenerator/data/models/meme.dart';
import 'package:memegenerator/data/repositories/list_with_ids_reactive_repository.dart';
import 'package:memegenerator/data/shared_preference_data.dart';

class MemesRepository extends ListWithIdsReactiveRepository<Meme> {
  factory MemesRepository.getInstance() => _instance ??=
      MemesRepository._internal(SharedPreferenceData.getInstance());

  MemesRepository._internal(this.spData);

  static MemesRepository? _instance;
  final SharedPreferenceData spData;

  @override
  Meme convertFromString(String rawItem) =>
      Meme.fromJson(json.decode(rawItem) as Map<String, dynamic>);

  @override
  String convertToString(Meme item) => json.encode(item.toJson());

  @override
  String getId(Meme item) => item.id;

  @override
  Future<List<String>> getRawData() => spData.getMemes();

  @override
  Future<bool> saveRawData(List<String> items) => spData.setMemes(items);
}
