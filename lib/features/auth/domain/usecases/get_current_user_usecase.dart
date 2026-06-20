import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<AppUser?, NoParams> {
  const GetCurrentUserUseCase(this._repo);
  final AuthRepository _repo;

  @override
  Future<Either<Failure, AppUser?>> call(NoParams _) =>
      _repo.getCurrentUser();
}