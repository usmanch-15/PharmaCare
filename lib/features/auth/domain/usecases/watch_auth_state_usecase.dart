import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthStateUseCase implements StreamUseCase<AppUser?, NoParams> {
  const WatchAuthStateUseCase(this._repo);
  final AuthRepository _repo;

  @override
  Stream<Either<Failure, AppUser?>> call(NoParams _) =>
      _repo.watchAuthState();
}