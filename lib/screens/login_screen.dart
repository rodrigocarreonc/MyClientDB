import 'package:flutter/material.dart';
import '../utils/auth_service.dart';
import '../utils/jwt_storage.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;  // Controla el estado entre login y registro
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Cambia entre login y registro
  void toggleAuth() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  // Maneja el login o el registro
  void authenticate() async {
    if (_formKey.currentState!.validate()) {
      final response = isLogin
          ? await ApiService.login(usernameController.text, passwordController.text)
          : await ApiService.register(
          nameController.text, usernameController.text, emailController.text, passwordController.text);

      if (response != null) {
        JwtStorage.saveToken(response);  // Guarda el token en el almacenamiento
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  HomeScreen()),  // Redirige a HomeScreen
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MyClientDB')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isLogin)  // Solo muestra el campo de nombre en el registro
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Name is required' : null,
                ),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => value!.isEmpty ? 'Username is required' : null,
              ),
              if (!isLogin)  // Solo muestra el campo de correo electrónico en el registro
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                  value!.isEmpty || !value.contains('@') ? 'Valid email is required' : null,
                ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Password is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: authenticate,  // Llama a authenticate que maneja login o registro
                child: Text(isLogin ? 'Login' : 'Register'),
              ),
              TextButton(
                onPressed: toggleAuth,  // Cambia entre login y registro
                child: Text(isLogin ? "Don't have an account? Register" : 'Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
