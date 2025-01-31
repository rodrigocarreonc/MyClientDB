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
  bool isLogin = true; // Controla el estado entre login y registro
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Variable para controlar la visibilidad de la contraseña

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
          ? await AuthService.login(usernameController.text, passwordController.text)
          : await AuthService.register(
          nameController.text, usernameController.text, emailController.text, passwordController.text);

      if (response != null) {
        JwtStorage.saveToken(response); // Guarda el token en el almacenamiento
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()), // Redirige a HomeScreen
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
      backgroundColor: Colors.white, // Fondo blanco
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Título de la app
                Text(
                  'MyClientDB',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isLogin ? 'Inicia sesión para continuar' : 'Regístrate para empezar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 40),
                if (!isLogin) // Solo muestra el campo de nombre en el registro
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) => value!.isEmpty ? 'Nombre es requerido' : null,
                  ),
                if (!isLogin) const SizedBox(height: 16),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) => value!.isEmpty ? 'Usuario es requerido' : null,
                ),
                const SizedBox(height: 16),
                if (!isLogin) // Solo muestra el campo de correo electrónico en el registro
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) =>
                    value!.isEmpty || !value.contains('@') ? 'Correo electrónico inválido' : null,
                  ),
                if (!isLogin) const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible, // Toggle password visibility
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Contraseña es requerida' : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5), // Azul destacado
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isLogin ? 'Iniciar sesión' : 'Registrarse',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: toggleAuth,
                    child: Text(
                      isLogin ? "¿No tienes cuenta? Regístrate" : "¿Ya tienes cuenta? Inicia sesión",
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}