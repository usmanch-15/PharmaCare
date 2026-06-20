import 'package:equatable/equatable.dart';

class VoiceSearchResult extends Equatable {
  const VoiceSearchResult({
    required this.recognizedText,
    required this.confidence,
    this.isFinal = false,
  });
  final String recognizedText;
  final double confidence;
  final bool isFinal;
  bool get isEmpty => recognizedText.trim().isEmpty;
  @override List<Object?> get props => [recognizedText, confidence, isFinal];
}

enum VoiceSearchStatus { idle, listening, processing, done, error, noPermission }