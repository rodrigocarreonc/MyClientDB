<?php
session_start();

if (!isset($_SESSION['access_token'])) {
    header('Location: login.php');
    exit;
}

$token = $_SESSION['access_token'];
$id = $_GET['id'] ?? null;
$db = $_GET['db'] ?? null;

if ($id && $db) {
    // Petición POST a list-tables
    $url_tables = "http://127.0.0.1:8000/api/list-tables/" . urlencode($id);
    $data_tables = json_encode(["database" => $db]);
    $options_tables = [
        "http" => [
            "header" => "Content-Type: application/json\r\n" .
                        "Authorization: Bearer " . $token . "\r\n",
            "method" => "POST",
            "content" => $data_tables
        ]
    ];
    $context_tables = stream_context_create($options_tables);
    $response_tables = file_get_contents($url_tables, false, $context_tables);

    if ($response_tables === FALSE) {
        die('Error occurred while fetching tables');
    }

    $tables = json_decode($response_tables, true);

    // Verificar si se ha enviado una consulta personalizada
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['query'])) {
        $query = $_POST['query'];
        $url_query = "http://127.0.0.1:8000/api/execute-query/" . urlencode($id);
        $data_query = json_encode(["database" => $db, "query" => $query]);
        $options_query = [
            "http" => [
                "header" => "Content-Type: application/json\r\n" .
                            "Authorization: Bearer " . $token . "\r\n",
                "method" => "POST",
                "content" => $data_query
            ]
        ];
        $context_query = stream_context_create($options_query);
        $response_query = file_get_contents($url_query, false, $context_query);

        if ($response_query === FALSE) {
            die('Error occurred while executing query');
        }

        $query_results = json_decode($response_query, true);
    }
} else {
    die('ID o base de datos no proporcionado');
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalle de la Base de Datos</title>
    <style>
        .container {
            display: flex;
        }
        .tables {
            width: 25%;
            padding: 10px;
            border-right: 1px solid #ddd;
        }
        .query-results {
            width: 75%;
            padding: 10px;
        }
    </style>
</head>
<body>
    <h1>Detalle de la Base de Datos</h1>
    <div class="container">
    <div class="tables">
            <h2>Tablas</h2>
            <?php if (!empty($tables)): ?>
                <?php foreach ($tables as $table): ?>
                    <div class="note">
                    <li><?php echo htmlspecialchars($table['Tables_in_' . $db]); ?></li>
                    </div>
                <?php endforeach; ?>
            <?php else: ?>
                <p>No se encontraron tablas para esta base de datos.</p>
            <?php endif; ?>
        </div>
        <div class="query-results">
            <h2>Resultados de la Consulta</h2>
            <form method="POST" action="database.php?id=<?php echo urlencode($id); ?>&db=<?php echo urlencode($db); ?>">
                <input type="text" name="query" placeholder="Escribe tu consulta aquí" required>
                <button type="submit">Run</button>
            </form>
            <?php if (!empty($query_results)): ?>
                <table border="1">
                    <thead>
                        <tr>
                            <?php foreach (array_keys($query_results[0]) as $column): ?>
                                <th><?php echo htmlspecialchars($column); ?></th>
                            <?php endforeach; ?>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($query_results as $row): ?>
                            <tr>
                                <?php foreach ($row as $value): ?>
                                    <td><?php echo htmlspecialchars($value); ?></td>
                                <?php endforeach; ?>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php else: ?>
                <p>No se encontraron resultados para esta consulta.</p>
            <?php endif; ?>
        </div>
    </div>
</body>
</html>