<?php

namespace App\Http\Controllers;

use App\Models\Usuario;
use App\Models\Connection;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:api', ['except' => ['login', 'register']]);
    }

    // Método para registrar un nuevo usuario
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'username' => 'required|string|unique:usuarios',
            'email' => 'required|string|email|unique:usuarios',
            'password' => 'required|string|min:6',
        ]);

        // Crear el usuario
        $user = Usuario::create([
            'name' => $request->name,
            'username' => $request->username,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        // Autenticar al usuario y generar un token
        $token = auth('api')->attempt(['username' => $request->username, 'password' => $request->password]);

        // Retornar respuesta con el mensaje y el token
        return response()->json([
            'message' => 'User registered successfully',
            'token' => $token,
        ]);
    }

    // Método para iniciar sesión con JWT
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        // Autenticación usando JWT
        if (! $token = auth()->attempt(['username' => $credentials['username'], 'password' => $credentials['password']])) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        return $this->respondWithToken($token);
    }


    // Método para obtener el usuario autenticado
    public function me()
    {
        return response()->json(auth()->user());
    }

    // Método para cerrar sesión e invalidar el token
    public function logout()
    {
        auth()->logout();
        return response()->json(['message' => 'Successfully logged out']);
    }

    // Método para refrescar el token JWT
    public function refresh()
    {
        return $this->respondWithToken(auth()->refresh());
    }

    // Estructura de respuesta con el token
    protected function respondWithToken($token)
    {
        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() / 1440
        ]);
    }
}