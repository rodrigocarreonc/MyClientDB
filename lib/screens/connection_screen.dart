import 'package:flutter/material.dart';
import '../utils/api_service.dart';
import '../utils/server.dart';

class ConnectionScreen extends StatefulWidget {
  final int connectionId;
  final String host;

  const ConnectionScreen({Key? key, required this.connectionId, required this.host}) : super(key: key);

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService apiService = ApiService(baseUrl: Server.baseUrl);

  List<Map<String, dynamic>> databases = [];
  List<Map<String, dynamic>> tables = [];
  String selectedDatabase = '';
  String query = '';
  List<Map<String, dynamic>> queryResult = [];
  bool isLoading = false;
  String errorMessage = '';

  final TextEditingController _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDatabases();
  }

  Future<void> _loadDatabases() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await apiService.fetchDatabases(widget.connectionId);
      setState(() {
        databases = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load databases: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadTables(String database) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await apiService.fetchTables(widget.connectionId, database);
      setState(() {
        tables = result;
        selectedDatabase = database;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load tables: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _runQuery() async {
    if (selectedDatabase.isEmpty) {
      _showMessage('Primero selecciona la base de datos.');
      return;
    }

    if (_queryController.text.trim().isEmpty) {
      _showMessage('Ingresa la consulta antes de ejecutar.');
      return;
    }

    setState(() {
      isLoading = true;
      queryResult = [];
    });

    try {
      final result = await apiService.executeQuery(
        widget.connectionId,
        selectedDatabase,
        _queryController.text.trim(),
      );
      setState(() {
        queryResult = List<Map<String, dynamic>>.from(result);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        queryResult = [];
        isLoading = false;
      });
      _showMessage(e.toString());
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aviso'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryResultTable() {
    if (queryResult.isEmpty) {
      return const Center(
        child: Text('No hay resultados para mostrar.'),
      );
    }

    final headers = queryResult.first.keys.toList();

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: headers
                .map((header) => DataColumn(label: Text(header)))
                .toList(),
            rows: queryResult.map((row) {
              return DataRow(
                cells: headers.map((header) {
                  return DataCell(Text(row[header]?.toString() ?? ''));
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildQuerySection() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _queryController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                labelText: 'Consulta',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                hintText: 'Escribe tu consulta aquí',
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 3,
            ),
          ),
          ElevatedButton(
            onPressed: _runQuery,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5), // Azul destacado
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Ejecutar',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildQueryResultTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseExpansionTile() {
    if (databases.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No hay bases de datos disponibles.'),
      );
    }
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 2,
      child: ExpansionTile(
        title: const Text('Bases de Datos'),
        children: databases.map((db) {
          final databaseName = db['Database'] ?? 'Desconocido';
          return ListTile(
            leading: Icon(Icons.storage, color: Colors.blue.shade800), // Icono de base de datos
            title: Text(databaseName),
            onTap: () {
              _loadTables(databaseName);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableExpansionTile() {
    if (tables.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No hay tablas disponibles para la base de datos seleccionada.'),
      );
    }
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 2,
      child: ExpansionTile(
        title: const Text('Tablas'),
        children: tables.map((table) {
          final tableName = table['Tables_in_$selectedDatabase'] ?? 'Desconocido';
          return ListTile(
            leading: Icon(Icons.table_chart, color: Colors.blue.shade800), // Icono de tabla
            title: Text(tableName),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: AppBar(
        title: Text(
          selectedDatabase.isEmpty
              ? 'Conexión: ${widget.host}' // Muestra el host si no hay base de datos seleccionada
              : 'Conexión: ${widget.host} \n$selectedDatabase', // Muestra el nombre de la base de datos seleccionada
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bases de Datos'),
            Tab(text: 'Consulta'),
          ],
          labelColor: Colors.blue.shade800, // Color de las pestañas seleccionadas
          unselectedLabelColor: Colors.grey.shade600, // Color de las pestañas no seleccionadas
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildDatabaseExpansionTile(),
                if (selectedDatabase.isNotEmpty) _buildTableExpansionTile(),
              ],
            ),
          ),
          Column(
            children: [
              _buildQuerySection(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _queryController.dispose();
    super.dispose();
  }
}