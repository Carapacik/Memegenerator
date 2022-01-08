import 'dart:ui';

import 'package:equatable/equatable.dart';

class MemeTextWithOffset extends Equatable {
  final String id;
  final String text;
  final Offset? offset;

  const MemeTextWithOffset({
    required this.id,
    required this.text,
    this.offset,
  });

  @override
  List<Object?> get props => [id, text, offset];
}
