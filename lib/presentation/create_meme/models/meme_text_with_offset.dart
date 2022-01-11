import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text.dart';

class MemeTextWithOffset extends Equatable {
  final MemeText memeText;
  final Offset? offset;

  const MemeTextWithOffset({
    required this.memeText,
    this.offset,
  });

  @override
  List<Object?> get props => [memeText, offset];
}
