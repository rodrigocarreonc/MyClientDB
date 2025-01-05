<?php
session_start();

if (!isset($_SESSION['access_token'])) {
    header('Location: login.php');
    exit;
}

$token = $_SESSION['access_token'];
$id = $_GET['id'] ?? null;

if ($id) {
    $url = "http://127.0.0.1:8000/api/databases/" . urlencode($id);
    $options = [
        "http" => [
            "header" => "Authorization: Bearer " . $token
        ]
    ];
    $context = stream_context_create($options);
    $response = file_get_contents($url, false, $context);

    if ($response === FALSE) {
        die('Error occurred');
    }

    $data = json_decode($response, true);
} else {
    die('ID no proporcionado');
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalle de la Conexión</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="notes">
        <h1>Bases de datos</h1>
        <?php if (!empty($data)): ?>
            <?php foreach ($data as $database): ?>
                <a href="database.php?id=<?php echo urlencode($id); ?>&db=<?php echo urlencode($database['Database']); ?>">
                    <div class="note">
                        <h3><?php echo htmlspecialchars($database['Database']); ?></h3>
                    </div>
                </a>
            <?php endforeach; ?>
        <?php else: ?>
            <p>No se encontraron datos para esta conexión.</p>
        <?php endif; ?>
    </div>
</body>
</html>