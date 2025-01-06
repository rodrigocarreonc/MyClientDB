<?php
// index.php
include("icons.php");

session_start();

if (!isset($_SESSION['access_token'])) {
    header('Location: login.php');
    exit;
}

$token = $_SESSION['access_token'];

// Obtener datos del usuario
$urlUser = 'http://127.0.0.1:8000/api/auth/me';
$chUser = curl_init($urlUser);
curl_setopt($chUser, CURLOPT_RETURNTRANSFER, true);
curl_setopt($chUser, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token,
]);
$responseUser = curl_exec($chUser);
curl_close($chUser);
$user = json_decode($responseUser, true);

// Verificar si el token es válido
if (isset($user['error']) || !$user) {
    header('Location: login.php');
    exit;
}

// Obtener notas
$urlConnections = 'http://127.0.0.1:8000/api/list-connections';
$chConnections = curl_init($urlConnections);
curl_setopt($chConnections, CURLOPT_RETURNTRANSFER, true);
curl_setopt($chConnections, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token,
]);
$responseConnections = curl_exec($chConnections);
curl_close($chConnections);
$connections = json_decode($responseConnections, true);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bienvenido</title>
    <link rel="icon" href="<?php echo $icon; ?>">
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="header">
        <h1>Bienvenido, <?php echo htmlspecialchars($user['username'] ?? 'Usuario desconocido'); ?></h1>
    </div>

    <div class="notes">
        <h2>Tus conexiones remotas:</h2>
        <button class="add-connection-button" onclick="window.location.href='add_connection.php'">
            <i class="fas fa-plus"></i> Agregar Conexión
        </button>
        <?php if (!empty($connections)): ?>
            <?php foreach ($connections as $connection): ?>
                <a href="connection.php?id=<?php echo urlencode($connection['id']); ?>">
                    <div class="note">
                        <h3><?php echo htmlspecialchars($connection['host']); ?></h3>
                        <small><?php echo htmlspecialchars($connection['port']); ?></small>
                        <p><?php echo htmlspecialchars($connection['username']); ?></p>
                    </div>
                </a>
            <?php endforeach; ?>
        <?php else: ?>
            <p>No hay conexiones disponibles :(.</p>
        <?php endif; ?>
    </div>
    <button class="logout-button" onclick="window.location.href='logout.php'">
        <i class="fas fa-sign-out-alt"></i> Cerrar sesión
    </button>
</body>
</html>