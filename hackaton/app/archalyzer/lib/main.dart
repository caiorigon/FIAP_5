import 'package:archalyzer/app/views/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/controllers/analysis_controller.dart';
import 'core/service_locator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => locator<AnalysisController>(),
      child: MaterialApp(
        title: 'Archalyzer',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shadowColor: Colors.black,
            elevation: 2,
          ),
          scaffoldBackgroundColor: Colors.blueGrey[50],
        ),
        home: const HomePage(),
      ),
    );
  }
}
