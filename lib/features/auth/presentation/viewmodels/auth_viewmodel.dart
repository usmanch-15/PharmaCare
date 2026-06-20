import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../providers/auth_providers.dart';

enum AuthStatus { idle, loading, authenticated, unauthenticated, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.errorMessage,
  });
  final AuthStatus status;
  final AppUser?   user;
  final String?    errorMessage;
  bool get isLoading => status == AuthStatus.loading;
  AuthState copyWith({
    AuthStatus? status, AppUser? user,
    String? errorMessage, bool clearError = false,
  }) => AuthState(
    status:       status       ?? this.status,
    user:         user         ?? this.user,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Watch Firebase auth state
    ref.listen(authStateProvider, (_, next) {
      next.when(
        data: (user) => state = user != null
            ? state.copyWith(status: AuthStatus.authenticated, user: user)
            : state.copyWith(status: AuthStatus.unauthenticated, user: null),
        loading: () {},
        error: (e, _) => state = state.copyWith(
            status: AuthStatus.error, errorMessage: e.toString()),
      );
    });
    return const AuthState();
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    final result = await ref
        .read(loginUseCaseProvider)(LoginParams(email: email, password: password));
    return result.fold(
      (f) {
        state = state.copyWith(
            status: AuthStatus.error, errorMessage: f.message);
        return false;
      },
      (user) {
        state = state.copyWith(
            status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    final result = await ref.read(registerUseCaseProvider)(
        RegisterParams(email: email, password: password,
            name: name, role: role));
    return result.fold(
      (f) {
        state = state.copyWith(
            status: AuthStatus.error, errorMessage: f.message);
        return false;
      },
      (user) {
        state = state.copyWith(
            status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider)(const NoParams());
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);