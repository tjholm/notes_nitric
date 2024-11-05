import 'package:nitric_sdk/nitric.dart';
import 'package:nitric_sdk/src/api/sql.dart';
import 'package:postgres/postgres.dart';
import 'dart:io';

SqlDatabase get db => Nitric.sql(
      'notes',
      migrations: "file://migrations/notes",
    );

Future<Connection?> getConnection() async {
  final nitricEnv = Platform.environment['NITRIC_ENVIRONMENT'];
  final dbRef = db;

  if (nitricEnv == "build") {
    print('Skipping connection during nitric build');
    return null;
  }

  final uri = Uri.parse(await dbRef.connectionString());
  final userInfoParts = uri.userInfo.split(':');
  final username = userInfoParts.length == 2 ? userInfoParts[0] : null;
  final password = userInfoParts.length == 2 ? userInfoParts[1] : null;
  final isUnixSocketParam = uri.queryParameters['is-unix-socket'];
  final applicationNameParam = uri.queryParameters['application_name'];
  final endpoint = Endpoint(
    host: uri.host,
    port: uri.port,
    database: uri.path.substring(1),
    username: username ?? uri.queryParameters['username'],
    password: password ?? uri.queryParameters['password'],
    isUnixSocket: isUnixSocketParam == '1',
  );

  final settings = ConnectionSettings(
    applicationName: applicationNameParam,
    sslMode: SslMode.values.byName(uri.queryParameters['sslmode'] ?? 'disable'),
  );

  return Connection.open(endpoint, settings: settings);
}
