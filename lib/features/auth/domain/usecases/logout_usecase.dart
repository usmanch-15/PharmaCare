import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  const LogoutUseCase(this._repo);
  final AuthRepository _repo;

  @override
  Future<Either<Failure, void>> call(NoParams _) => _repo.logout();
}