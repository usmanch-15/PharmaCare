import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);
  final AuthRemoteDataSource _remote;

  Either<Failure, T> _h<T>(Object e) {
    if (e is ServerException) return Left(ServerFailure(e.message));
    return Left(UnexpectedFailure(e.toString()));
  }

  AppUser _fromMap(Map<String, dynamic> d) => AppUser(
        uid:      d['uid']   as String,
        name:     d['name']  as String? ?? '',
        email:    d['email'] as String? ?? '',
        role:     UserRole.fromString(d['role'] as String?),
        isActive: d['isActive'] as bool? ?? true,
      );

  @override
  Future<Either<Failure, AppUser>> login(
      String email, String password) async {
    try { return Right(_fromMap(await _remote.login(email, password))); }
    catch (e) { return _h(e); }
  }

  @override
  Future<Either<Failure, AppUser>> register(
      String email, String password, String name, String role) async {
    try { return Right(_fromMap(
        await _remote.register(email, password, name, role))); }
    catch (e) { return _h(e); }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try { await _remote.logout(); return const Right(null); }
    catch (e) { return _h(e); }
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async {
    try {
      final d = await _remote.getCurrentUser();
      return Right(d == null ? null : _fromMap(d));
    } catch (e) { return _h(e); }
  }

  @override
  Stream<Either<Failure, AppUser?>> watchAuthState() =>
      _remote.watchAuthState()
          .map<Either<Failure, AppUser?>>(
              (d) => Right(d == null ? null : _fromMap(d)))
          .handleError((e) => _h<AppUser?>(e));
}