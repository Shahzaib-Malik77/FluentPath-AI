import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'data/database/database_helper.dart';
import 'providers/user_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/vocabulary_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/streak_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the SQLite database connection before booting UI
  await DatabaseHelper.instance.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider()),
      ],
      child: const FluentPathApp(),
    ),
  );
}

class FluentPathApp extends StatelessWidget {
  const FluentPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FluentPath AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Merienda',
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.bgDarkGreen,
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Merienda',
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.brightGreen,
          secondary: AppColors.brightGreen,
          surface: AppColors.bgMedBrown,
          onSurface: AppColors.textDark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
