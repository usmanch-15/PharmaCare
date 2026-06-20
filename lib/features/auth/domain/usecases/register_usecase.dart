import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<AppUser, RegisterParams> {
  const RegisterUseCase(this._repo);
  final AuthRepository _repo;

  @override
  Future<Either<Failure, AppUser>> call(RegisterParams p) async {
    if (p.name.trim().isEmpty) {
      return const Left(ValidationFailure('Name is required.'));
    }
    if (p.email.trim().isEmpty) {
      return const Left(ValidationFailure('Email is required.'));
    }
    if (p.password.length < 6) {
      return const Left(ValidationFailure('Password must be at least 6 characters.'));
    }
    return _repo.register(
        p.email.trim(), p.password, p.name.trim(), p.role);
  }
}

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });
  final String email;
  final String password;
  final String name;
  final String role;
  @override List<Object> get props => [email, name, role];
}