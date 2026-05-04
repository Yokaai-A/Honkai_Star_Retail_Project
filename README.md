# 🚀 Honkai Star Retail

Mobile Hybrid Solution Laboratorium Project

## 🛠️ Tech Stack
*   **Runtime**: Node.js (v23.11.0+)
*   **Framework**: Express.js
*   **Database**: MySQL (XAMPP)
*   **Authentication**: JSON Web Token (JWT) & BcryptJS
*   **Security**: Crypto (untuk generate alfanumerik token)

## 🔐 Authentication & Security Compliance
Berdasarkan persyaratan teknis proyek, sistem ini telah mengimplementasikan:
*   **Password Hashing**: Menggunakan `bcryptjs` dengan salt round 10 untuk keamanan database.
*   **Bearer Token**: Menghasilkan token alfanumerik unik dengan panjang >20 karakter.
*   **Request Verification**: Menggunakan Middleware untuk memverifikasi token pada rute administratif.

## 📂 Project Structure
```text
server/
├── config/             # Konfigurasi koneksi MySQL
├── controllers/        # Logika bisnis (Auth & Resource management)
├── middleware/         # Verifikasi Bearer Token (Auth Middleware)
├── routes/             # Definisi routing API
├── .env                # Konfigurasi variabel lingkungan (Secret)
└── index.js            # Entry point aplikasi
