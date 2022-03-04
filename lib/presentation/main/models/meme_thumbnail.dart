import 'package:equatable/equatable.dart';

class MemeThumbnail extends Equatable {
  const MemeThumbnail({
    required this.memeId,
    required this.fullImageUrl,
  });

  final String memeId;
  final String fullImageUrl;

  @override
  List<Object?> get props => [memeId, fullImageUrl];
}
