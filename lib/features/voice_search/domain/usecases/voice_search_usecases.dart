import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/voice_search_result.dart';
import '../repositories/voice_search_repository.dart';

class CheckMicPermissionUseCase implements UseCase<bool, NoParams> {
  const CheckMicPermissionUseCase(this._repo);
  final VoiceSearchRepository _repo;
  @override Future<Either<Failure, bool>> call(NoParams _) => _repo.hasPermission();
}

class RequestMicPermissionUseCase implements UseCase<bool, NoParams> {
  const RequestMicPermissionUseCase(this._repo);
  final VoiceSearchRepository _repo;
  @override Future<Either<Failure, bool>> call(NoParams _) => _repo.requestPermission();
}

class StartListeningUseCase implements StreamUseCase<VoiceSearchResult, NoParams> {
  const StartListeningUseCase(this._repo);
  final VoiceSearchRepository _repo;
  @override Stream<Either<Failure, VoiceSearchResult>> call(NoParams _) =>
      _repo.startListening();
}

class StopListeningUseCase implements UseCase<void, NoParams> {
  const StopListeningUseCase(this._repo);
  final VoiceSearchRepository _repo;
  @override Future<Either<Failure, void>> call(NoParams _) => _repo.stopListening();
}