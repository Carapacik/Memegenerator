import 'package:equatable/equatable.dart';
import 'package:memegenerator/data/models/meme.dart';

class MemesWithDocsPath extends Equatable {
  const MemesWithDocsPath(this.memes, this.docsPath);

  final List<Meme> memes;
  final String docsPath;

  @override
  List<Object?> get props => [memes, docsPath];
}
