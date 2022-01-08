import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/shared_preferences_data.dart';
import 'package:rxdart/rxdart.dart';

class MemesRepository {
  final updater = PublishSubject<Null>();
  final SharedPreferenceData spData;

  static MemesRepository? _instance;

  factory MemesRepository.getInstance() =>
      _instance ??= MemesRepository._internal(SharedPreferenceData.getInstance());

  MemesRepository._internal(this.spData);

  Future<bool> addToMemes(final Meme meme) async {
    final rawMemes = await spData.getMemes();
    rawMemes.add(json.encode(meme.toJson()));
    return _setRawMemes(rawMemes);
  }

  Future<bool> removeFromMemes(final String id) async {
    final memes = await getMemes();
    memes.removeWhere((meme) => meme.id == id);
    return _setMemes(memes);
  }

  Future<List<Meme>> getMemes() async {
    final rawMemes = await spData.getMemes();
    return rawMemes
        .map(
          (rawMeme) => Meme.fromJson(json.decode(rawMeme) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<Meme?> getMeme(final String id) async {
    final memes = await getMemes();
    return memes.firstWhereOrNull((meme) => meme.id == id);
  }

  Stream<List<Meme>> observeMemes() async* {
    yield await getMemes();
    await for (final _ in updater) {
      yield await getMemes();
    }
  }

  Future<bool> _setMemes(final List<Meme> memes) async {
    final rawMemes = memes.map((meme) => json.encode(meme.toJson())).toList();
    return _setRawMemes(rawMemes);
  }

  Future<bool> _setRawMemes(final List<String> rawMemes) {
    updater.add(null);
    return spData.setMemes(rawMemes);
  }
}
