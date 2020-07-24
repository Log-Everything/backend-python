import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginWidget extends StatefulWidget {
  final AuthorizedBuilder builder;

  const LoginWidget({Key key, this.builder}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginWidgetState();
  }
}

typedef AuthorizedBuilder = Widget Function(
    BuildContext context, FirebaseUser user);

class LoginWidgetState extends State<LoginWidget> {
  bool loading = true;
  bool loginSide = true;
  FirebaseUser firebaseUser;

  TextEditingController _emailController;
  TextEditingController _passwordController;

  void _loadData() async {
    final result = await _auth.currentUser();
    setState(() {
      firebaseUser = result;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  Future<void> _loginViaGoogle(BuildContext context) async {
    print('logging in');
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      print('logging in 2');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('logging in 3');
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('credentials');

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      setState(() {
        firebaseUser = user;
        loading = false;
      });
    } catch (e, st) {
      print("Error: ${e}");
      rethrow;
    }
  }

  Future<void> _loginViaEmail(BuildContext context) async {
    print('logging in');

    try {
      final AuthCredential credential = EmailAuthProvider.getCredential(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print('credentials');

      AuthResult result;
      if (loginSide) {
        result = await _auth.signInWithCredential(credential);
      } else {
        result = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      final FirebaseUser user = result.user;

      setState(() {
        firebaseUser = user;
        loading = false;
      });
    } catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      Scaffold.of(context).showSnackBar(snackBar);
      print("Error: ${e}");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return CircularProgressIndicator();
    }
    if (firebaseUser != null) {
      return widget.builder(
        context,
        firebaseUser,
      );
    }
    return Material(
      child: Scaffold(
        body: Builder(builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(48),
            child: Container(
              alignment: AlignmentDirectional.center,
              child: LimitedBox(
                maxWidth: 400.0,
                child: Column(
                  children: [
                    Text(
                      loginSide ? 'Log-In' : 'Create an account',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'E-mail',
                      ),
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                    RaisedButton(
                      child: Text(loginSide
                          ? 'Log in via e-mail'
                          : 'Sign-up via e-mail'),
                      onPressed: () => _loginViaEmail(context),
                    ),
                    RaisedButton(
                      child: Text('Use Google'),
                      onPressed: () => _loginViaGoogle(context),
                    ),
                    FlatButton(
                      child: Text(loginSide
                          ? "Don't have an account? Sign-Up"
                          : "Go back to login"),
                      onPressed: () {
                        setState(() {
                          loginSide = !loginSide;
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
