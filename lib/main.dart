import 'package:flutter/material.dart';
import 'package:techbuddy/core/app_env.dart';
import 'package:techbuddy/core/constants.dart';
import 'package:techbuddy/screens/drawer_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();
  runApp(const TechBuddyApp());
}

class TechBuddyApp extends StatelessWidget {
  const TechBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: AppTextStyles.appTextTheme,
        primaryTextTheme: AppTextStyles.appTextTheme,
      ),
      home: const DrawerScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
    );
  }
}
