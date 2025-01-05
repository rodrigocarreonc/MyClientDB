<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Connection;
use Illuminate\Support\Facades\DB;

class ConnectionController extends Controller
{
    public function listConnections(){
        $cliente = auth()->user();
        $connections = Connection::where('id_usuario', $cliente->id)->select('id','host', 'port', 'username', 'password')
        ->get();
        return response()->json($connections);
    }

    public function addConnection(Request $request){
        $cliente = auth()->user();
        $request->validate([
            'host' => 'required|string',
            'port' => 'required|integer',
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        $connection = Connection::create([
            'host' => $request->host,
            'port' => $request->port,
            'username' => $request->username,
            'password' => $request->password,
            'id_usuario' => $cliente->id,
        ]);

        return response()->json([
            'message' => "conecction add",
            "conecction" => $connection
        ],201);
    }

    public function getDatabases($id, Request $request){
        $connection = Connection::find($id);

        if(!$connection){
            return response()->json([
                'message' => 'Conexión no encontrada o inexistente'
            ], 404);
        }

        // Configuración de la conexión a la base de datos remota
        config([
            'database.connections.mysql_remote' => [
                'driver' => 'mysql',
                'host' => $connection->host,
                'port' => $connection->port,
                'database' => 'information_schema', // Usamos information_schema para obtener bases de datos
                'username' => $connection->username,
                'password' => $connection->password,
                'charset' => 'utf8mb4',
                'collation' => 'utf8mb4_unicode_ci',
            ],
        ]);

        try {
            // Consultar las bases de datos
            $databases = DB::connection('mysql_remote')->select('SHOW DATABASES');
            return response()->json($databases);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Connection failed: ' . $e->getMessage()], 500);
        }
    }

    // Método para conectarse a una base de datos remota y listar sus tablas
    public function listTables($id, Request $request){
        $connection = Connection::find($id);

        if(!$connection){
            return response()->json([
                'message' => 'Conexión no encontrada o inexistente'
            ], 404);
        }

        $request->validate([
            'database' => 'required|string',
        ]);

        config([
            'database.connections.mysql_remote' => [
                'driver' => 'mysql',
                'host' => $connection->host,
                'port' => $connection->port,
                'database' => $request->database,
                'username' => $connection->username,
                'password' => $connection->password,
                'charset' => 'utf8mb4',
                'collation' => 'utf8mb4_unicode_ci',
            ],
        ]);

        try {
            $tables = DB::connection('mysql_remote')->select('SHOW TABLES');
            return response()->json($tables);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Connection failed: ' . $e->getMessage()], 500);
        }
    }

    // Método para ejecutar consultas SQL en la base de datos remota
    public function executeQuery($id, Request $request){
        $connection = Connection::find($id);

        if(!$connection){
            return response()->json([
                'message' => 'Conexión no encontrada o inexistente'
            ], 404);
        }

        $request->validate([
            'database' => 'required|string',
            'query' => 'required|string',
        ]);

        config([
            'database.connections.mysql_remote' => [
                'driver' => 'mysql',
                'host' => $connection->host,
                'port' => $connection->port,
                'username' => $connection->username,
                'database' => $request->database,
                'password' => $connection->password,
                'charset' => 'utf8mb4',
                'collation' => 'utf8mb4_unicode_ci',
            ],
        ]);

        try {
            $sqlQuery = $request->input('query');
            $result = DB::connection('mysql_remote')->select($sqlQuery);
            return response()->json($result);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Query execution failed: ' . $e->getMessage()], 500);
        }
    }
}
