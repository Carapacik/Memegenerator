import 'package:equatable/equatable.dart';

class TemplateFull extends Equatable {
  const TemplateFull({
    required this.id,
    required this.fullImagePath,
  });

  final String id;
  final String fullImagePath;

  @override
  List<Object?> get props => [id, fullImagePath];
}
