import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'position.g.dart';

@JsonSerializable()
class Position extends Equatable {
  const Position({
    required this.left,
    required this.top,
  });

  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);

  final double top;
  final double left;

  Map<String, dynamic> toJson() => _$PositionToJson(this);

  @override
  List<Object?> get props => [left, top];
}
