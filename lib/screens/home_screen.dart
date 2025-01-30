import 'package:flutter/material.dart';
import 'package:myclientdb/utils/auth_service.dart';
import 'package:myclientdb/utils/jwt_storage.dart';
import 'connection_screen.dart';
import 'login_screen.dart';
import '../utils/server.dart';
import '../utils/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _futureConnections;
  final ApiService apiService = ApiService(baseUrl: Server.baseUrl);

  bool _obscureText = true; // To control password visibility
  String? _host, _port, _username, _password;

  @override
  void initState() {
    super.initState();
    _futureConnections = apiService.getConnections();
  }

  Future<void> _refreshConnections() async {
    setState(() {
      _futureConnections = apiService.getConnections();
    });
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final token = await JwtStorage.getToken();

      if (token != null && token.isNotEmpty) {
        final response = await AuthService.logout(token);
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

  void _showAddConnectionForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Agregar Nueva Conexión'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Host'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el host';
                          }
                          return null;
                        },
                        onSaved: (value) => _host = value!,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Puerto'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el puerto';
                          }
                          if (int.tryParse(value) == null) {
                            return 'El puerto debe ser un número entero';
                          }
                          return null;
                        },
                        onSaved: (value) => _port = value!,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Usuario'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el usuario';
                          }
                          return null;
                        },
                        onSaved: (value) => _username = value!,
                      ),
                      TextFormField(
                        obscureText: _obscureText, // Control password visibility
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText; // Toggle password visibility
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa la contraseña';
                          }
                          return null;
                        },
                        onSaved: (value) => _password = value!,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // Convertir el puerto a int
                      final int port = int.parse(_port!);

                      final response = await apiService.addConnection(
                        host: _host!,
                        port: port, // Enviar como int
                        username: _username!,
                        password: _password!,
                      );

                      if (response != null && response['message'] == 'conecction add') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Conexión agregada con éxito')),
                        );
                        _refreshConnections();
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al agregar la conexión')),
                        );
                      }
                    }
                  },
                  child: Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
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
        child: FutureBuilder<List<Map<String, dynamic>>>( // Future to load connections
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
                        "¡¡Agrega tu primer conexión!!.",
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
                              connectionId: conexion['connection_id']),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddConnectionForm(context),
        child: Icon(Icons.add),
        tooltip: 'Agregar Conexión',
      ),
    );
  }
}
