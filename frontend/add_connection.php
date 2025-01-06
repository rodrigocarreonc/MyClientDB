<?php
session_start();

if (!isset($_SESSION['access_token'])) {
    header('Location: login.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $host = $_POST['host'];
    $port = $_POST['port'];
    $username = $_POST['username'];
    $password = $_POST['password'];
    $token = $_SESSION['access_token'];

    $url = "http://127.0.0.1:8000/api/add-connection";
    $data = json_encode([
        "host" => $host,
        "port" => $port,
        "username" => $username,
        "password" => $password
    ]);

    $options = [
        "http" => [
            "header" => "Content-Type: application/json\r\n" .
                        "Authorization: Bearer " . $token . "\r\n",
            "method" => "POST",
            "content" => $data
        ]
    ];

    $context = stream_context_create($options);
    $response = file_get_contents($url, false, $context);

    if ($response === FALSE) {
        die('Error occurred while adding connection');
    }

    echo "<script>
        alert('Conexión realizada exitosamente');
        window.location.href = 'index.php';
    </script>";
    exit;
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agregar Nueva Conexión</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Agregar Nueva Conexión</h1>
    <form method="POST" action="add_connection.php">
        <label for="host">Host:</label>
        <input type="text" id="host" name="host" required>
        <br>
        <label for="port">Puerto:</label>
        <input type="text" id="port" name="port" required>
        <br>
        <label for="username">Usuario:</label>
        <input type="text" id="username" name="username" required>
        <br>
        <label for="password">Contraseña:</label>
        <input type="password" id="password" name="password" required>
        <br>
        <button type="submit">Guardar Conexión</button>
    </form>
    <button onclick="window.location.href='index.php'">Cancelar</button>
</body>
</html>