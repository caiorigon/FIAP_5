import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

import '../app/controllers/analysis_controller.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';

// Create a global instance of GetIt
final GetIt locator = GetIt.instance;

void setupLocator() {
  // --- SERVICES ---
  // Register services as singletons. They are created once and the same
  // instance is provided every time.
  locator.registerLazySingleton(() => AuthService());

  // --- DIO ---
  final dio = Dio();
  dio.options.baseUrl = dotenv.env['BASE_URI'] ?? 'http://localhost:8000';
  final authToken = dotenv.env['AUTH_TOKEN'] ?? "";
  dio.options.headers = {'Authorization': 'Bearer $authToken'};
  // The ApiService depends on AuthService. GetIt will resolve this for you.
  locator.registerLazySingleton(() => ApiService(dio: dio));

  // --- CONTROLLERS / NOTIFIERS ---
  // Register controllers as a 'factory'. This means a new instance
  // is created every time you ask for one.
  locator.registerFactory(() => AnalysisController());
}
