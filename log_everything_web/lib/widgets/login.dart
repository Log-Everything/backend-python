import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:log_everything_web/dependency_injection.dart';
import 'package:log_everything_web/repositories/login_repository.dart';

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
  final _loginRepository = getIt<LoginRepository>();

  bool loading = true;
  bool loginSide = true;
  FirebaseUser firebaseUser;

  TextEditingController _emailController;
  TextEditingController _passwordController;

  void _loadData() async {
    _loginRepository.firebaseUser.listen((result) {
      setState(() {
        firebaseUser = result;
        loading = false;
      });
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
    try {
      await _loginRepository.loginWithGoogle();
    } catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      Scaffold.of(context).showSnackBar(snackBar);
      rethrow;
    }
  }

  Future<void> _loginViaEmail(BuildContext context) async {
    print('logging in');

    try {
      final email = _emailController.text;
      final password = _passwordController.text;
      if (loginSide) {
        _loginRepository.loginWithEmail(email, password);
      } else {
        _loginRepository.createEmailAccount(email, password);
      }
    } catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      Scaffold.of(context).showSnackBar(snackBar);
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
