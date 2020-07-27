import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:log_everything_web/repositories/login_repository.dart';

GetIt getIt = GetIt.instance;

void dependencyInjectionSetup() {
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<LoginRepository>(() => LoginRepository());
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
}
