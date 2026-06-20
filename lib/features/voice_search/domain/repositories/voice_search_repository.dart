import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/voice_search_result.dart';

abstract class VoiceSearchRepository {
  Future<Either<Failure, bool>> hasPermission();
  Future<Either<Failure, bool>> requestPermission();
  Future<Either<Failure, bool>> isAvailable();
  Stream<Either<Failure, VoiceSearchResult>> startListening();
  Future<Either<Failure, void>> stopListening();
  Future<Either<Failure, void>> cancelListening();
}