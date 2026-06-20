import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/voice_search_result.dart';
import '../viewmodels/voice_search_viewmodel.dart';

/// Pulsing mic button — drop into any search bar.
///
/// ```dart
/// VoiceSearchButton(
///   onResult: (text) => searchController.text = text,
/// )
/// ```
class VoiceSearchButton extends ConsumerWidget {
  const VoiceSearchButton({super.key, required this.onResult});
  final ValueChanged<String> onResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(voiceSearchViewModelProvider);
    final vm    = ref.read(voiceSearchViewModelProvider.notifier);

    // Deliver final text to caller
    ref.listen(voiceSearchViewModelProvider, (_, next) {
      if (next.status == VoiceSearchStatus.done &&
          next.finalText.isNotEmpty) {
        onResult(next.finalText);
        vm.reset();
      }
    });

    return GestureDetector(
      onTap: state.isListening ? vm.stopListening : vm.startListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: state.isListening
              ? const Color(0xFFF44336)
              : const Color(0xFF1565C0),
          shape: BoxShape.circle,
          boxShadow: state.isListening
              ? [BoxShadow(
                  color: const Color(0xFFF44336).withOpacity(0.5),
                  blurRadius: 12, spreadRadius: 2)]
              : [],
        ),
        child: Icon(
          state.isListening ? Icons.stop_rounded : Icons.mic_rounded,
          color: Colors.white, size: 18,
        ),
      ),
    );
  }
}