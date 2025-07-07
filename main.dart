import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:project_ilearn/firebase_options.dart';
import 'package:project_ilearn/providers/auth_provider.dart';
import 'package:project_ilearn/providers/theme_provider.dart';
import 'package:project_ilearn/providers/student_provider.dart';
import 'package:project_ilearn/providers/educator_provider.dart';
import 'package:project_ilearn/utils/app_theme.dart';
import 'package:project_ilearn/utils/routes.dart';
import 'package:project_ilearn/screens/splash_screen.dart';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Menangani error inisialisasi Firebase
    log('Error initializing Firebase: $e');
    // Masih lanjut dengan app meskipun Firebase gagal inisialisasi
  }
  
  // Set orientasi yang diizinkan
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => EducatorProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'iLearn',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      builder: (context, child) {
        // Menambahkan responsive builder untuk skala font yang lebih baik
        final mediaQueryData = MediaQuery.of(context);
        final textScaler = mediaQueryData.textScaler.clamp(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.2,
        );
      
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: textScaler),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}