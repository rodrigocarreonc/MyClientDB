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

  void _showConnectionSuccessDialog(BuildContext context, String message) {
    final bool isSuccess = message == 'Connection successful';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.warning, // Ícono condicional
                color: isSuccess ? Colors.green.shade800 : Colors.orange.shade800, // Color condicional
                size: 40,
              ),
              const SizedBox(height: 18),
              Text(
                message,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        );
      },
    );
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuye los botones
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          // Convertir el puerto a int
                          final int port = int.parse(_port!);

                          try {
                            final response = await apiService.testConnection(
                              host: _host!,
                              port: port, // Enviar como int
                              username: _username!,
                              password: _password!,
                            );

                            _showConnectionSuccessDialog(context, response['message']); // Muestra el mensaje de éxito
                          } catch (e) {
                            _showConnectionSuccessDialog(context, e.toString());
                          }
                        }
                      },
                      child: Text(
                        'Probar',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
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

                          if (response['message'] == 'conecction add') {
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
                      child: Text(
                        'Agregar',
                        style: TextStyle(color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditConnectionForm(BuildContext context, Map<String, dynamic> connection) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController hostController = TextEditingController(text: connection['host']);
    final TextEditingController portController = TextEditingController(text: connection['port'].toString());
    final TextEditingController usernameController = TextEditingController(text: connection['username']);
    final TextEditingController passwordController = TextEditingController(text: connection['password']);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Editar Conexión'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: hostController,
                        decoration: InputDecoration(labelText: 'Host'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el host';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: portController,
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
                      ),
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(labelText: 'Usuario'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el usuario';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscureText,
                        readOnly: true,// Control password visibility
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState((){
                                passwordController.clear();
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
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final int connectionId = connection['connection_id'];
                      final String host = hostController.text;
                      final int port = int.parse(portController.text);
                      final String username = usernameController.text;
                      final String password = passwordController.text;

                      try {
                        final response = await apiService.editConnection(
                          connectionId: connectionId,
                          host: host,
                          port: port,
                          username: username,
                          password: password,
                        );

                        if (response['message'] == 'Conexión actualizada') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Conexión actualizada con éxito')),
                          );
                          _refreshConnections();
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al actualizar la conexión')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Guardar',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int connectionId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Conexión'),
          content: Text('¿Estás seguro de que deseas eliminar esta conexión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final response = await apiService.deleteConnection(connectionId);
                  if (response['message'] == 'Conexión eliminada') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Conexión eliminada con éxito')),
                    );
                    _refreshConnections();
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al eliminar la conexión')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Text(
                'Eliminar',
                style: TextStyle(color: Colors.red.shade800),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: AppBar(
        title: Text(
          'Lista de Conexiones',
          style: TextStyle(color: Colors.grey.shade800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.exit_to_app, color: Colors.grey.shade800),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      Text(
                        'No hay conexiones disponibles',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "¡¡Agrega tu primer conexión!!.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
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
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.cloud, color: Colors.blue),
                    title: Text(
                      'Host: ${conexion['host']}',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    subtitle: Text(
                      'Puerto: ${conexion['port']}\nUsuario: ${conexion['username']}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditConnectionForm(context, conexion);
                        } else if (value == 'delete') {
                          _showDeleteConfirmationDialog(context, conexion['connection_id']);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Editar'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Eliminar'),
                        ),
                      ],
                    ),
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
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue.shade800,
        tooltip: 'Agregar Conexión',
      ),
    );
  }
}