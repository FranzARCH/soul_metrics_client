import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:soul_metrics_client/core/config/api_config.dart';

// ==========================================
// IMPORTS: MÓDULO DE HISTORIAL
// ==========================================
import 'package:soul_metrics_client/features/history_results/data/repositories/history_repository.dart'; 
import 'package:soul_metrics_client/features/history_results/domain/repositories/ihistory_repository.dart';
import 'package:soul_metrics_client/features/history_results/domain/usecases/get_prediction_history_usecase.dart';
import 'package:soul_metrics_client/features/history_results/presentation/viewmodels/history_viewmodel.dart';

// ==========================================
// IMPORTS: MÓDULO DE PROFILE INSIGHTS (NUEVO)
// ==========================================
import 'package:soul_metrics_client/features/personality_test/data/repositories/profile_repository.dart';
import 'package:soul_metrics_client/features/personality_test/domain/repositories/iprofile_repository.dart';
import 'package:soul_metrics_client/features/personality_test/domain/usecases/get_holistic_profile_usecase.dart';
import 'package:soul_metrics_client/features/personality_test/presentation/viewmodels/profile_viewmodel.dart';

// ==========================================
// IMPORTS: MÓDULO DE PERSONALITY TEST
// ==========================================
import 'package:soul_metrics_client/features/personality_test/data/datasources/assessment_datasource.dart'; 
import 'package:soul_metrics_client/features/personality_test/data/repositories/test_repository.dart'; 
import 'package:soul_metrics_client/features/personality_test/domain/repositories/itest_repository.dart';
import 'package:soul_metrics_client/features/personality_test/domain/usecases/get_questions_usecase.dart';
import 'package:soul_metrics_client/features/personality_test/domain/usecases/submit_assessment_usecase.dart';
import 'package:soul_metrics_client/features/personality_test/presentation/viewmodels/question_viewmodel.dart';

// ==========================================
// IMPORTS: MÓDULO DE AUTENTICACIÓN
// ==========================================
import 'features/auth/data/datasources/auth_api_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/services/auth_token_store.dart';
import 'features/auth/domain/repositories/iauth_repository.dart';
import 'features/auth/domain/usecases/get_profile_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/restore_session_usecase.dart';
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';

final locator = GetIt.instance;

void setupLocator() {
  // ==========================================
  // CORE & EXTERNAL SERVICES
  // ==========================================
  locator.registerLazySingleton<http.Client>(() => http.Client());
  locator.registerLazySingleton<AuthTokenStore>(() => AuthTokenStore());

  // ==========================================
  // AUTH MODULE
  // ==========================================
  locator.registerLazySingleton<AuthApiDataSource>(() => AuthApiDataSource(
        client: locator(),
        baseUrl: ApiConfig.baseUrl,
      ));

  locator.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(locator(), locator()),
  );

  locator.registerLazySingleton(() => LoginUseCase(locator()));
  locator.registerLazySingleton(() => RegisterUseCase(locator()));
  locator.registerLazySingleton(() => GetProfileUseCase(locator()));
  locator.registerLazySingleton(() => UpdateProfileUseCase(locator()));
  locator.registerLazySingleton(() => LogoutUseCase(locator()));
  locator.registerLazySingleton(() => RestoreSessionUseCase(locator()));

  locator.registerFactory(() => AuthViewModel(
    loginUseCase: locator(),
    registerUseCase: locator(),
    getProfileUseCase: locator(),
    updateProfileUseCase: locator(),
    logoutUseCase: locator(),
    restoreSessionUseCase: locator(),
  ));

  // ==========================================
  // PERSONALITY TEST MODULE (Django REST API)
  // ==========================================
  locator.registerLazySingleton<AssessmentApiDataSource>(
    () => AssessmentApiDataSource(
      client: locator(),
      baseUrl: ApiConfig.baseUrl,
    ),
  );

  locator.registerLazySingleton<ITestRepository>(
    () => TestRepositoryImpl(
      dataSource: locator(),
      tokenStore: locator<AuthTokenStore>(),
    ),
  );

  locator.registerLazySingleton(() => GetQuestionsUseCase(locator()));
  locator.registerLazySingleton(() => SubmitAssessmentUseCase(locator()));

  locator.registerFactory(() => QuestionViewModel(
        getQuestionsUseCase: locator(),
        submitAssessmentUseCase: locator(),
  ));

  // ==========================================
  // HISTORY MODULE
  // ==========================================
  locator.registerLazySingleton<IHistoryRepository>(
    () => HistoryRepositoryImpl(
      client: locator(), 
      tokenStore: locator(),
      baseUrl: ApiConfig.baseUrl,
    ),
  );

  locator.registerLazySingleton(() => GetPredictionHistoryUseCase(locator()));
  locator.registerFactory(() => HistoryViewModel(getPredictionHistoryUseCase: locator()));

  // ==========================================
  // PERSONALITY PROFILE INSIGHTS MODULE
  // ==========================================
  locator.registerLazySingleton<IProfileRepository>(
    () => ProfileRepositoryImpl(
      client: locator(), 
      tokenStore: locator(),
      baseUrl: ApiConfig.baseUrl,
    ),
  );

  locator.registerLazySingleton(() => GetHolisticProfileUseCase(locator()));
  locator.registerFactory(() => ProfileViewModel(getHolisticProfileUseCase: locator()));
}