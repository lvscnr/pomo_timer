import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomo_timer/firebase_options.dart';
import 'package:pomo_timer/signin_screen.dart';
import 'package:pomo_timer/splash_screen.dart';
import 'package:pomo_timer/utils/color_utils.dart';
//import 'package:pomo_timer/timer_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return MaterialApp(
      title: 'Stay Productive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: hexStringToColor("0A7B79"))),
      ),
      routes: {
        '/': (context) => SplashScreen(),
        '/signin': (context) => SignInScreen(),
        //'/timer': (context) => PomodoroTimer(),
      },
      //home: SignInScreen(),
    );
  }
}
