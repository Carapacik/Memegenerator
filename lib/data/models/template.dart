import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'template.g.dart';

@JsonSerializable()
class Template extends Equatable {
  const Template({required this.id, required this.imageUrl});

  factory Template.fromJson(Map<String, dynamic> json) =>
      _$TemplateFromJson(json);

  final String id;
  final String imageUrl;

  Map<String, dynamic> toJson() => _$TemplateToJson(this);

  @override
  List<Object?> get props => [id, imageUrl];
}
