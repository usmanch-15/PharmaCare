import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../data/datasources/speech_recognition_datasource.dart';
import '../../data/repositories/voice_search_repository_impl.dart';
import '../../domain/repositories/voice_search_repository.dart';
import '../../domain/usecases/voice_search_usecases.dart';

final speechToTextProvider   = Provider<SpeechToText>((_) => SpeechToText());
final speechDataSourceProvider = Provider<SpeechRecognitionDataSource>(
    (ref) => SpeechRecognitionDataSource(ref.read(speechToTextProvider)));
final voiceSearchRepositoryProvider = Provider<VoiceSearchRepository>(
    (ref) => VoiceSearchRepositoryImpl(ref.read(speechDataSourceProvider)));
final checkMicPermissionUseCaseProvider =
    Provider((ref) => CheckMicPermissionUseCase(ref.read(voiceSearchRepositoryProvider)));
final requestMicPermissionUseCaseProvider =
    Provider((ref) => RequestMicPermissionUseCase(ref.read(voiceSearchRepositoryProvider)));
final startListeningUseCaseProvider =
    Provider((ref) => StartListeningUseCase(ref.read(voiceSearchRepositoryProvider)));
final stopListeningUseCaseProvider =
    Provider((ref) => StopListeningUseCase(ref.read(voiceSearchRepositoryProvider)));