import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/jwt_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

void main() {
  runApp(const MyClientDBApp());
}

class MyClientDBApp extends StatelessWidget {
  const MyClientDBApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyClientDB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // Cambiar la home a SplashScreen
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await JwtStorage.getToken();  // Obtener el token guardado

    try {
      if (token != null && token.isNotEmpty && !JwtDecoder.isExpired(token)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      print("Error decoding JWT: $e");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),  // Muestra un indicador de carga mientras verifica el token
    );
  }
}

