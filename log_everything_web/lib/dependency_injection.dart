import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:log_everything_web/repositories/login_repository.dart';
import 'package:log_everything_web/repositories/projects_repository.dart';

GetIt getIt = GetIt.instance;

void dependencyInjectionSetup() {
  getIt.registerLazySingleton<Dio>(() {
    final options = BaseOptions(
      baseUrl: "http://localhost:8080",
      connectTimeout: 5000,
      receiveTimeout: 3000,
      responseType: ResponseType.json,
    );
    return Dio(options);
  });
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<LoginRepository>(() => LoginRepository());
  getIt.registerLazySingleton<ProjectsRepository>(() => ProjectsRepository());
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
}
