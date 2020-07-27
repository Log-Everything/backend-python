import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:log_everything_web/dependency_injection.dart';
import 'package:log_everything_web/tools/downloader.dart';

class ProjectsRepository {
  final cache = Cache<FirebaseUser, UserProjectsRepository>(
    keyProvider: (user) => UserProjectsRepository(user: user),
  );
}

class UserProjectsRepository {
  final FirebaseUser user;
  Downloader<Project> projects;

  UserProjectsRepository({@required this.user}) : assert(user != null) {
    projects = Downloader<Project>(download: () async {
      final dio = getIt<Dio>();
      final response = await dio.request<Project>(
        '/v1/project',
        options: Options(
          headers: {
            'Authorization': await user.getIdToken(),
          },
        ),
      );
      return response.data;
    });
  }
}

class Project {
  final String token;

  Project({@required this.token}) : assert(token != null);
  factory Project.fromJson(Map<String, dynamic> json) => Project(
        token: json['token'],
      );
  Map<String, dynamic> toJson() => {
        'token': token,
      };
}
