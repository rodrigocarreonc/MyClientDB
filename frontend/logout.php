<?php
// logout.php
session_start();

if (isset($_SESSION['access_token'])) {
    $token = $_SESSION['access_token'];

    // Enviar solicitud POST al endpoint de logout
    $urlLogout = 'https://api.notas.rodrigocarreon.com/api/auth/logout';
    $chLogout = curl_init($urlLogout);
    curl_setopt($chLogout, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($chLogout, CURLOPT_POST, true);
    curl_setopt($chLogout, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $token,
    ]);
    $responseLogout = curl_exec($chLogout);
    curl_close($chLogout);

    // Decodificar la respuesta y mostrar el mensaje
    $logoutResponse = json_decode($responseLogout, true);
    if (isset($logoutResponse['message'])) {
        echo "<p>" . $logoutResponse['message'] . "</p>";
    }
}

session_destroy();
header('Location: login.php');
exit;