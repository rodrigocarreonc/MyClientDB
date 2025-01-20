import 'package:flutter/material.dart';
import 'package:myclientdb/utils/http_get.dart';
import 'package:myclientdb/utils/auth_service.dart';
import 'package:myclientdb/utils/jwt_storage.dart';
import 'connection_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  // Función para manejar el cierre de sesión
  Future<void> _logout(BuildContext context) async {
    try {
      final token = await JwtStorage.getToken(); // Obtener el token JWT desde el almacenamiento local

      if (token != null && token.isNotEmpty) {
        // Enviar la solicitud al servidor para invalidar el JWT
        final response = await ApiService.logout(token);

        if (response != null && response.statusCode == 200) {
          // El servidor ha invalidado el token, ahora lo borramos localmente
          await JwtStorage.clearToken();

          // Redirigir al Login Screen después de borrar el token
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          // Si la respuesta no es exitosa, puedes mostrar un error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to logout.')),
          );
        }
      }
    } catch (e) {
      // Si ocurre algún error en la solicitud
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Conexiones'),
        // Botón en la esquina superior izquierda para cerrar sesión
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app), // Icono para el botón de logout
          onPressed: () => _logout(context), // Llamada a la función de cierre de sesión
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( // Lista de conexiones
        future: fetchConnections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay conexiones disponibles'));
          }

          final conexiones = snapshot.data!;
          return ListView.builder(
            itemCount: conexiones.length,
            itemBuilder: (context, index) {
              final conexion = conexiones[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.cloud),
                  title: Text('Host: ${conexion['host']}'),
                  subtitle: Text(
                    'Puerto: ${conexion['port']}'
                    '\nUsuario: ${conexion['username']}',
                  ),
                  isThreeLine: true, // Permite mostrar múltiples líneas en el subtitle
                  onTap: () {
                    // Navegar a ConnectionScreen y pasar la información de la conexión
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConnectionScreen(host: conexion['host'],connectionId: conexion['id']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
