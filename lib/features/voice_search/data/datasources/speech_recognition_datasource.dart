import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/voice_search_result.dart';

class SpeechRecognitionDataSource {
  SpeechRecognitionDataSource(this._stt);
  final SpeechToText _stt;
  final StreamController<VoiceSearchResult> _controller =
      StreamController<VoiceSearchResult>.broadcast();

  Future<bool> isAvailable() async => _stt.isAvailable;

  Future<bool> hasPermission() async {
    try {
      final available = await _stt.initialize();
      return available;
    } catch (e) {
      throw PermissionException(e.toString());
    }
  }

  Future<bool> requestPermission() async {
    try {
      return await _stt.initialize(
        onError: (e) => _controller.addError(
            PermissionException(e.errorMsg)),
      );
    } catch (e) {
      throw PermissionException(e.toString());
    }
  }

  Stream<VoiceSearchResult> startListening() {
    _stt.listen(
      onResult: (result) {
        _controller.add(VoiceSearchResult(
          recognizedText: result.recognizedWords,
          confidence:     result.confidence,
          isFinal:        result.finalResult,
        ));
      },
      listenFor:    const Duration(seconds: 30),
      pauseFor:     const Duration(seconds: 3),
      localeId:     'en_US',
      cancelOnError: true,
    );
    return _controller.stream;
  }

  Future<void> stopListening() async => _stt.stop();
  Future<void> cancelListening() async => _stt.cancel();
}