// Auth feature — full barrel export
export 'domain/entities/app_user.dart';
export 'domain/repositories/auth_repository.dart';
export 'domain/usecases/login_usecase.dart';
export 'domain/usecases/register_usecase.dart';
export 'domain/usecases/logout_usecase.dart';
export 'domain/usecases/get_current_user_usecase.dart';
export 'domain/usecases/watch_auth_state_usecase.dart';
export 'data/datasources/auth_remote_datasource.dart';
export 'data/repositories/auth_repository_impl.dart';
export 'presentation/providers/auth_providers.dart';
export 'presentation/viewmodels/auth_viewmodel.dart';
export 'presentation/screens/login_screen.dart';
export 'presentation/screens/register_screen.dart';
export 'presentation/widgets/role_guard.dart';