import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:memegenerator/data/models/text_with_position.dart';

part 'meme.g.dart';

@JsonSerializable()
class Meme extends Equatable {
  const Meme({
    required this.id,
    required this.texts,
    this.memePath,
  });

  factory Meme.fromJson(Map<String, dynamic> json) => _$MemeFromJson(json);

  final String id;
  final List<TextWithPosition> texts;
  final String? memePath;

  Map<String, dynamic> toJson() => _$MemeToJson(this);

  @override
  List<Object?> get props => [id, texts, memePath];
}
