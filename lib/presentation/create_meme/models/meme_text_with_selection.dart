import 'package:equatable/equatable.dart';
import 'package:memegenerator/presentation/create_meme/models/meme_text.dart';

class MemeTextWithSelection extends Equatable {
  const MemeTextWithSelection({required this.memeText, required this.selected});

  final MemeText memeText;
  final bool selected;

  @override
  List<Object?> get props => [memeText, selected];
}
