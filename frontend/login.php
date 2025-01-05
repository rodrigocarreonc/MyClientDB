<?php
// login.php
include("icons.php");
session_start();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];

    // Configura el endpoint de autenticación
    $url = 'http://127.0.0.1:8000/api/auth/login';

    // Datos a enviar en formato JSON
    $data = [
        'username' => $username,
        'password' => $password
    ];

    // Inicializa cURL
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json'
    ]);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));

    // Ejecuta la solicitud y obtiene la respuesta
    $response = curl_exec($ch);
    curl_close($ch);

    // Decodifica la respuesta JSON
    $result = json_decode($response, true);

    if (isset($result['access_token'])) {
        $_SESSION['access_token'] = $result['access_token'];
        header('Location: index.php');
        exit;
    } else {
        $error = 'Credenciales inválidas o error en el servidor';
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <link rel="icon" href="<?php echo $icon; ?>">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f4f4f9;
        }
        .login-container {
            width: 100%;
            max-width: 400px;
            background: white;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            border: black 1px solid;
            margin: 10px;
        }
        .login-container h2 {
            margin-bottom: 20px;
            font-size: 1.5rem;
            text-align: center;
        }
        .login-container input {
            width: 95%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .login-container button {
            width: 100%;
            padding: 10px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 1rem;
            cursor: pointer;
        }
        .login-container button:hover {
            background-color: #0056b3;
        }
        .error {
            color: red;
            font-size: 0.9rem;
            text-align: center;
        }
        .password-box {
            width: 105%;
        }
        .password-box input{
            width: 82%;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>Iniciar Sesión</h2>
        <?php if (isset($error)) { echo "<p class='error'>$error</p>"; } ?>
        <form method="POST">
            <input type="text" name="username" placeholder="Usuario" required>
            <div class="password-box">
                <input type="password" name="password" placeholder="Contraseña" required>
                <i class="fa fa-eye" style="font-size: 20px;"></i>
            </div>
            <button type="submit">Entrar</button>
        </form>
    </div>

    <script>
        const eye = document.querySelector('.fa-eye');
        const password = document.querySelector('input[type="password"]');

        eye.addEventListener('click', () => {
            if (password.type === 'password') {
                password.type = 'text';
                eye.classList.add('fa-eye-slash');
                eye.classList.remove('fa-eye');
            } else {
                password.type = 'password';
                eye.classList.remove('fa-eye-slash');
                eye.classList.add('fa-eye');
            }
        });
    </script>
</body>
</html>