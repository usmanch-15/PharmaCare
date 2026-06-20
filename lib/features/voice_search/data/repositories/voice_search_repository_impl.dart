import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/voice_search_result.dart';
import '../../domain/repositories/voice_search_repository.dart';
import '../datasources/speech_recognition_datasource.dart';

class VoiceSearchRepositoryImpl implements VoiceSearchRepository {
  const VoiceSearchRepositoryImpl(this._ds);
  final SpeechRecognitionDataSource _ds;

  Either<Failure, T> _h<T>(Object e) {
    if (e is PermissionException) return Left(PermissionFailure(e.message));
    return Left(UnexpectedFailure(e.toString()));
  }

  @override Future<Either<Failure, bool>> hasPermission() async {
    try { return Right(await _ds.hasPermission()); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, bool>> requestPermission() async {
    try { return Right(await _ds.requestPermission()); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, bool>> isAvailable() async {
    try { return Right(await _ds.isAvailable()); } catch (e) { return _h(e); }
  }
  @override Stream<Either<Failure, VoiceSearchResult>> startListening() =>
      _ds.startListening()
         .map<Either<Failure, VoiceSearchResult>>(Right.new)
         .handleError((e) => _h<VoiceSearchResult>(e));
  @override Future<Either<Failure, void>> stopListening() async {
    try { await _ds.stopListening(); return const Right(null); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, void>> cancelListening() async {
    try { await _ds.cancelListening(); return const Right(null); } catch (e) { return _h(e); }
  }
}