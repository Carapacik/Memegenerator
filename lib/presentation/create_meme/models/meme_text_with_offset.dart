import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:memegenerator/presentation/create_meme/models/meme_text.dart';

class MemeTextWithOffset extends Equatable {
  const MemeTextWithOffset({
    required this.memeText,
    this.offset,
  });

  final MemeText memeText;
  final Offset? offset;

  @override
  List<Object?> get props => [memeText, offset];
}
