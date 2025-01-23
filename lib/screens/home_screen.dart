import 'package:flutter/material.dart';
import 'package:myclientdb/utils/http_get.dart';
import 'package:myclientdb/utils/auth_service.dart';
import 'package:myclientdb/utils/jwt_storage.dart';
import 'connection_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _futureConnections;

  @override
  void initState() {
    super.initState();
    _futureConnections = fetchConnections();
  }

  // Función para refrescar la lista de conexiones
  Future<void> _refreshConnections() async {
    setState(() {
      _futureConnections = fetchConnections();
    });
  }

  // Función para manejar el cierre de sesión
  Future<void> _logout(BuildContext context) async {
    try {
      final token = await JwtStorage.getToken();

      if (token != null && token.isNotEmpty) {
        final response = await ApiService.logout(token);
        if (response != null && response.statusCode == 200) {
          await JwtStorage.clearToken();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to logout.')),
          );
        }
      }
    } catch (e) {
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
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () => _logout(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshConnections,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureConnections,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              final errorMessage = snapshot.error.toString();
              return Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        errorMessage.contains("Upss..")
                            ? Icons.wifi_off_outlined
                            : Icons.error_outline,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        errorMessage.contains("Upss..")
                            ? errorMessage
                            : "Error: $errorMessage",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Desliza hacia abajo para intentar nuevamente.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'No hay conexiones disponibles',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Desliza hacia abajo para refrescar.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
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
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConnectionScreen(
                              host: conexion['host'],
                              connectionId: conexion['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
