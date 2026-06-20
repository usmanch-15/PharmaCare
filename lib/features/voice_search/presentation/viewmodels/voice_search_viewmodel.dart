import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/voice_search_result.dart';
import '../../domain/usecases/voice_search_usecases.dart';
import '../providers/voice_search_providers.dart';

class VoiceSearchState {
  const VoiceSearchState({
    this.status = VoiceSearchStatus.idle,
    this.partialText = '',
    this.finalText = '',
    this.errorMessage,
  });
  final VoiceSearchStatus status;
  final String partialText;
  final String finalText;
  final String? errorMessage;
  bool get isListening => status == VoiceSearchStatus.listening;
  VoiceSearchState copyWith({
    VoiceSearchStatus? status, String? partialText, String? finalText,
    String? errorMessage, bool clearError = false,
  }) => VoiceSearchState(
    status: status ?? this.status,
    partialText: partialText ?? this.partialText,
    finalText: finalText ?? this.finalText,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

class VoiceSearchViewModel extends Notifier<VoiceSearchState> {
  StreamSubscription<dynamic>? _sub;

  @override VoiceSearchState build() {
    ref.onDispose(() { _sub?.cancel(); });
    return const VoiceSearchState();
  }

  Future<void> startListening() async {
    final hasPermission = await ref
        .read(checkMicPermissionUseCaseProvider)(const NoParams());
    final permitted = hasPermission.fold((_) => false, (v) => v);
    if (!permitted) {
      final req = await ref
          .read(requestMicPermissionUseCaseProvider)(const NoParams());
      final granted = req.fold((_) => false, (v) => v);
      if (!granted) {
        state = state.copyWith(
            status: VoiceSearchStatus.noPermission,
            errorMessage: 'Microphone permission denied.');
        return;
      }
    }

    state = state.copyWith(
        status: VoiceSearchStatus.listening,
        partialText: '', finalText: '', clearError: true);

    final stream = ref.read(startListeningUseCaseProvider)(const NoParams());
    _sub = stream.listen((either) {
      either.fold(
        (f) => state = state.copyWith(
            status: VoiceSearchStatus.error, errorMessage: f.message),
        (result) {
          state = state.copyWith(partialText: result.recognizedText);
          if (result.isFinal) {
            state = state.copyWith(
                status: VoiceSearchStatus.done,
                finalText: result.recognizedText);
          }
        },
      );
    });
  }

  Future<void> stopListening() async {
    await _sub?.cancel();
    await ref.read(stopListeningUseCaseProvider)(const NoParams());
    state = state.copyWith(status: VoiceSearchStatus.done);
  }

  void reset() {
    _sub?.cancel();
    state = const VoiceSearchState();
  }
}

final voiceSearchViewModelProvider =
    NotifierProvider<VoiceSearchViewModel, VoiceSearchState>(
        VoiceSearchViewModel.new);