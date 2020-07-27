import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_everything_web/dependency_injection.dart';
import 'package:log_everything_web/repositories/projects_repository.dart';
import 'package:log_everything_web/widgets/login.dart';
import 'package:log_everything_web/widgets/menu.dart';

abstract class ProjectBlocState extends Equatable {
  @override
  List<Object> get props => [];
}

class ProjectBlocStateLoading extends ProjectBlocState {}

class ProjectBlocStateLoaded extends ProjectBlocState {
  final String token;

  ProjectBlocStateLoaded({@required this.token}) : assert(token != null);
}

class ProjectBlocStateError extends ProjectBlocState {}

class ProjectBloc extends Cubit<ProjectBlocState> {
  final _projectsRepository = getIt<ProjectsRepository>();
  final FirebaseUser user;
  StreamSubscription _subscription;
  ProjectBloc({@required this.user})
      : assert(user != null),
        super(ProjectBlocStateLoading()) {
    _subscription = _projectsRepository.cache.get(user).projects.data.listen(
      (event) {
        emit(ProjectBlocStateLoaded(token: event.token));
      },
      onError: (error) {
        emit(ProjectBlocStateError());
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}

class ProjectsScreen extends StatelessWidget {
  ProjectsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu(),
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Project'),
      ),
      body: LoginWidget(builder: (context, user) {
        return BlocProvider<ProjectBloc>(
          create: (_) => ProjectBloc(user: user),
          child: BlocBuilder<ProjectBloc, ProjectBlocState>(
              builder: (context, snapshot) {
            if (snapshot is ProjectBlocStateLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot is ProjectBlocStateError) {
              return Center(
                child: Text('Error'),
              );
            }
            final result = snapshot as ProjectBlocStateLoaded;
            return Center(
              child: Text('Token:' + result.token),
            );
          }),
        );
      }),
    );
  }
}
