<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

include "../connection.php";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email    = isset($_POST['email'])        ? trim($_POST['email'])        : '';
    $new_pass = isset($_POST['new_password']) ? trim($_POST['new_password']) : '';

    if (empty($email) || empty($new_pass)) {
        echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
        exit;
    }

    if (strlen($new_pass) < 8) {
        echo json_encode(["status" => "error", "message" => "Kata sandi minimal 8 karakter"]);
        exit;
    }

    // Cek apakah email terdaftar
    $stmt = mysqli_prepare($conn, "SELECT id_user FROM users WHERE email = ?");
    mysqli_stmt_bind_param($stmt, "s", $email);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    if (mysqli_num_rows($result) > 0) {
        $hashed = password_hash($new_pass, PASSWORD_DEFAULT);

        $stmt2 = mysqli_prepare($conn, "UPDATE users SET password = ? WHERE email = ?");
        mysqli_stmt_bind_param($stmt2, "ss", $hashed, $email);

        if (mysqli_stmt_execute($stmt2)) {
            echo json_encode(["status" => "success", "message" => "Password berhasil diubah"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Gagal mengubah password"]);
        }
        mysqli_stmt_close($stmt2);
    } else {
        echo json_encode(["status" => "error", "message" => "Email tidak ditemukan"]);
    }

    mysqli_stmt_close($stmt);
}
?>