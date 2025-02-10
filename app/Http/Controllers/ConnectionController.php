<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Connection;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\QueryException;

class ConnectionController extends Controller
{
    public function listConnections(){
        $cliente = auth()->user();
        $connections = Connection::where('user_id', $cliente->user_id)->select('connection_id','host', 'port', 'username', 'password')
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
            'password' => encrypt($request->password),
            'user_id' => $cliente->user_id,
        ]);

        return response()->json([
            'message' => "conecction add",
            "conecction" => $connection
        ],201);
    }

    public function editConnection($id, Request $request){
        $connection = Connection::find($id);
        if(!$connection){
            return response()->json([
                'message' => 'Conexión no encontrada o inexistente'
            ], 404);
        }
        $request->validate([
            'host' => 'sometimes|string',
            'port' => 'sometimes|integer',
            'username' => 'sometimes|string',
            'password' => 'sometimes|string',
        ]);

        $connection->update([
            'host' => $request->host,
            'port' => $request->port,
            'username' => $request->username,
            'password' => encrypt($request->password),
        ]);

        return response()->json([
            'message' => 'Conexión actualizada',
            'connection' => $connection
        ]);
    }

    public function deleteConnection($id){
        $connection = Connection::find($id);
        if(!$connection){
            return response()->json([
                'message' => 'Conexión no encontrada o inexistente'
            ], 404);
        }
        $connection->delete();
        return response()->json([
            'message' => 'Conexión eliminada'
        ]);
    }

    public function testConnection(Request $request){
        $request->validate([
            'host' => 'required|string',
            'port' => 'required|integer',
            'username' => 'required|string',
            'password' => 'required|string',
        ]);
        
        config([
            'database.connections.mysql_remote' => [
                'driver' => 'mysql',
                'host' => $request->host,
                'port' => $request->port,
                'database' => 'information_schema',
                'username' => $request->username,
                'password' => $request->password,
                'charset' => 'utf8mb4',
                'collation' => 'utf8mb4_unicode_ci',
            ],
        ]);

        try {
            DB::connection('mysql_remote')->getPdo();
            return response()->json(['message' => 'Connection successful'], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Connection failed: ' . $e->getMessage()], 404);
        }
    }

    public function getDatabases($id, Request $request){
        $connection = Connection::find($id);

        if(!$connection){
            return response()->json([
                'message' => 'Conexión no encontrada o inexistente'
            ], 404);
        }

        $password = decrypt($connection->password);

        // Configuración de la conexión a la base de datos remota
        config([
            'database.connections.mysql_remote' => [
                'driver' => 'mysql',
                'host' => $connection->host,
                'port' => $connection->port,
                'database' => 'information_schema', // Usamos information_schema para obtener bases de datos
                'username' => $connection->username,
                'password' => $password,
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
        
        $password = decrypt($connection->password);

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
                'password' => $password,
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
        
        $password = decrypt($connection->password);

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
                'password' => $password,
                'charset' => 'utf8mb4',
                'collation' => 'utf8mb4_unicode_ci',
            ],
        ]);

        try {
            $sqlQuery = $request->input('query');
            $result = DB::connection('mysql_remote')->select($sqlQuery);
            return response()->json($result);
        } catch (QueryException $e) {
            $errorCode = $e->errorInfo[1];
            if ($errorCode == 1146) { // Error code for "Table doesn't exist"
                // Extract table name from the error message
                preg_match("/Table '.*\.(.*)' doesn't exist/", $e->getMessage(), $matches);
                $tableName = $matches[1] ?? 'unknown';
                return response()->json(['message' => "Table '{$request->database}.{$tableName}' doesn't exist"], 406);
            }
            return response()->json(['message' => 'Query execution failed: ' . $e->getMessage()], 500);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Query execution failed: ' . $e->getMessage()], 500);
        }
    }
}