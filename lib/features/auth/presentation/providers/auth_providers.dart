import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../../customers/presentation/providers/customer_providers.dart'
    show firestoreProvider;

final firebaseAuthProvider =
Provider<FirebaseAuth>((_) => FirebaseAuth.instance);

final authRemoteDataSourceProvider =
Provider<AuthRemoteDataSource>((ref) => AuthRemoteDataSourceImpl(
  ref.read(firebaseAuthProvider),
  ref.read(firestoreProvider),
));

final authRepositoryProvider = Provider<AuthRepository>(
        (ref) => AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider)));

final loginUseCaseProvider =
Provider((ref) => LoginUseCase(ref.read(authRepositoryProvider)));

final registerUseCaseProvider =
Provider((ref) => RegisterUseCase(ref.read(authRepositoryProvider)));

final logoutUseCaseProvider =
Provider((ref) => LogoutUseCase(ref.read(authRepositoryProvider)));

final getCurrentUserUseCaseProvider =
Provider((ref) => GetCurrentUserUseCase(ref.read(authRepositoryProvider)));

final authStateProvider = StreamProvider((ref) {
  final repo = ref.read(authRepositoryProvider);
  return repo
      .watchAuthState()
      .map((either) => either.fold((_) => null, (user) => user));
});