import 'dart:ui';

import 'package:equatable/equatable.dart';

class MemeTextOffset extends Equatable {
  const MemeTextOffset({
    required this.id,
    required this.offset,
  });

  final String id;
  final Offset offset;

  @override
  List<Object?> get props => [id, offset];
}
