import 'package:get_it/get_it.dart';
import 'package:soul_metrics_client/features/personality_test/data/datasources/test_mock.dart';
import 'package:soul_metrics_client/features/personality_test/data/repositories/test_repository.dart';
import 'package:soul_metrics_client/features/personality_test/domain/repositories/itest_repository.dart';
import 'package:soul_metrics_client/features/personality_test/domain/usecases/get_questions_usecase.dart';
import 'package:soul_metrics_client/features/personality_test/domain/usecases/submit_assessment_usecase.dart';
import 'package:soul_metrics_client/features/personality_test/presentation/viewmodels/question_viewmodel.dart';
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

  // 1. Data Source del Cuestionario
  locator.registerLazySingleton<TestMockDataSource>(() => TestMockDataSource());

  // 2. Repositorio del Cuestionario 
  locator.registerLazySingleton<ITestRepository>(() => TestRepositoryImpl(locator()));

  // 3. Casos de Uso
  locator.registerLazySingleton(() => GetQuestionsUseCase(locator()));
  locator.registerLazySingleton(() => SubmitAssessmentUseCase(locator()));

  // 4. ViewModel (Factory para limpiar respuestas al iniciar un nuevo test)
  locator.registerFactory(() => QuestionViewModel(
        getQuestionsUseCase: locator(),
        submitAssessmentUseCase: locator(),
  ));
}