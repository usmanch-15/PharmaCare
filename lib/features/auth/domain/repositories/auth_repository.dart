import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>>  login(String email, String password);
  Future<Either<Failure, AppUser>>  register(
      String email, String password, String name, String role);
  Future<Either<Failure, void>>     logout();
  Future<Either<Failure, AppUser?>> getCurrentUser();
  Stream<Either<Failure, AppUser?>> watchAuthState();
}