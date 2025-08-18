import 'package:archalyzer/app/views/home/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/controllers/analysis_controller.dart';
import 'core/service_locator.dart'; // <-- Import the locator
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  setupLocator();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Use the locator to create the controller instance
      create: (context) => locator<AnalysisController>(), // <-- CHANGE
      child: MaterialApp(
        title: 'Archalyzer',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: const HomePage(),
      ),
    );
  }
}