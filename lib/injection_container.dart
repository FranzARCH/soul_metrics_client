import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/user_mock.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/iauth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<AuthMockDataSource>(() => AuthMockDataSource());

  locator.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(locator()),
  );

  locator.registerLazySingleton(() => LoginUseCase(locator()));
  locator.registerLazySingleton(() => RegisterUseCase(locator()));

  locator.registerFactory(() => AuthViewModel(
    loginUseCase: locator(),
    registerUseCase: locator(),
  ));
}