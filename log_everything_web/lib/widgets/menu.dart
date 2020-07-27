import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_everything_web/dependency_injection.dart';
import 'package:log_everything_web/repositories/login_repository.dart';

abstract class BlocMenuState extends Equatable {
  @override
  List<Object> get props => [];
}

class BlocMenuStateLoggedIn extends BlocMenuState {
  final String name;

  BlocMenuStateLoggedIn({@required this.name}) : assert(name != null);
}

class BlocMenuStateInitializing extends BlocMenuState {}

class BlocMenuStateLoggedOut extends BlocMenuState {}

class BlocMenu extends Cubit<BlocMenuState> {
  final _loginRepository = getIt<LoginRepository>();
  StreamSubscription _subscription;
  BlocMenu() : super(BlocMenuStateInitializing()) {
    _subscription = _loginRepository.firebaseUser.listen((event) {
      if (event == null) {
        emit(BlocMenuStateLoggedOut());
      } else {
        emit(BlocMenuStateLoggedIn(
          name: event.displayName ?? event.email ?? '',
        ));
      }
    });
  }

  @override
  Future<void> close() async {
    _subscription?.cancel();

    return await super.close();
  }

  void logOut() {
    _loginRepository.signOut();
  }
}

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocMenu>(
        create: (_) => BlocMenu(),
        child: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: BlocBuilder<BlocMenu, BlocMenuState>(
                    builder: (context, snapshot) {
                  var header = 'Welcome';
                  if (snapshot is BlocMenuStateLoggedIn) {
                    header = 'Hi ' + snapshot.name;
                  }
                  return Text(
                    header,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  );
                }),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                },
                leading: Icon(Icons.message),
                title: Text('Project'),
              ),
              BlocBuilder<BlocMenu, BlocMenuState>(
                  builder: (context, value) => value is BlocMenuStateLoggedIn
                      ? ListTile(
                          title: Text('Log-out'),
                          onTap: () {
                            context.bloc<BlocMenu>().logOut();
                          },
                        )
                      : SizedBox.shrink()),
            ],
          ),
        ));
  }
}
