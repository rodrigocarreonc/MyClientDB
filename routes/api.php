<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ConnectionController;
/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::group([

    'middleware' => 'api',
    'prefix' => 'auth'

], function ($router) {
    Route::post('register', [AuthController::class,'register']);
    Route::post('login', [AuthController::class,'login']);
    Route::post('logout', [AuthController::class,'logout']);
    Route::post('refresh', [AuthController::class,'refresh']);
    Route::post('me', [AuthController::class,'me']);

});

Route::group([
    'middleware' => 'auth:api',
], function ($router) {
    Route::get('/list-connections', [ConnectionController::class, 'listConnections']);
    Route::post('/add-connection', [ConnectionController::class, 'addConnection']);
    Route::get('/databases/{id}', [ConnectionController::class, 'getDatabases']);
    Route::post('/list-tables/{id}', [ConnectionController::class, 'listTables']);
    Route::post('/execute-query/{id}', [ConnectionController::class, 'executeQuery']);
});