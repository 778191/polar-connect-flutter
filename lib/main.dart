import 'package:polar_connect/pages/files.dart';
import 'package:polar_connect/widgets/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../pages/main_menu.dart';
import '../pages/polar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: CustomColors.background,
      systemNavigationBarColor: CustomColors.background,
      statusBarBrightness: Brightness.light));

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polar Connect',
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainMenu(),
        '/polar': (context) => PolarConnect(),
        '/files': (context) => FileBrowser(),
      },
    );
  }
}
