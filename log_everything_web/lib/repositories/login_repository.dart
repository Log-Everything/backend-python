import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:log_everything_web/dependency_injection.dart';
import 'package:rxdart/rxdart.dart';

class LoginRepository {
  final _firebaseAuth = getIt<FirebaseAuth>();
  final GoogleSignIn _googleSignIn = getIt<GoogleSignIn>();
  final changes = PublishSubject<String>();

  Stream<FirebaseUser> get firebaseUser async* {
    yield await _firebaseAuth.currentUser();
    await for (final _ in changes) {
      yield await _firebaseAuth.currentUser();
    }
  }

  Future<void> loginWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _firebaseAuth.signInWithCredential(credential);
    changes.add(null);
    return result;
  }

  Future<AuthResult> createEmailAccount(String email, String password) async {
    final result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    changes.add(null);
    return result;
  }

  Future<AuthResult> loginWithEmail(String email, String password) async {
    final AuthCredential credential = EmailAuthProvider.getCredential(
      email: email,
      password: password,
    );
    final result = await _firebaseAuth.signInWithCredential(credential);
    changes.add(null);
    return result;
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
    changes.add(null);
  }
}
