import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<AppUser, LoginParams> {
  const LoginUseCase(this._repo);
  final AuthRepository _repo;

  @override
  Future<Either<Failure, AppUser>> call(LoginParams p) async {
    if (p.email.trim().isEmpty) {
      return const Left(ValidationFailure('Email is required.'));
    }
    if (p.password.length < 6) {
      return const Left(ValidationFailure('Password must be at least 6 characters.'));
    }
    return _repo.login(p.email.trim(), p.password);
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});
  final String email;
  final String password;
  @override List<Object> get props => [email, password];
}