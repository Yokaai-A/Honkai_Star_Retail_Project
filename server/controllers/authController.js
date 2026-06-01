const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto'); // Built-in Node.js untuk generate string random

exports.register = async (req, res) => {
    const { username, password, role } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        await db.execute(
            'INSERT INTO users (username, password, role) VALUES (?, ?, ?)',
            [username, hashedPassword, role || 'user']
        );
        res.status(201).json({ message: 'User berhasil didaftarkan' });
    } catch (error) {
        res.status(500).json({ message: 'Error', error: error.message });
    }
};

exports.login = async (req, res) => {
    const { username, password } = req.body;

    try {
        // 1. Cari user di database
        const [users] = await db.execute('SELECT * FROM users WHERE username = ?', [username]);

        if (users.length === 0) {
            return res.status(401).json({ message: 'Username atau password salah' });
        }

        const user = users[0];

        // 2. Cek password (bcrypt)
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Username atau password salah' });
        }

        // 3. Generate Token Alfanumerik (Min 20 Karakter)
        // Kita gunakan crypto agar benar-benar random dan alfanumerik
        const customToken = crypto.randomBytes(15).toString('hex'); // Menghasilkan 30 karakter hex

        // 4. Bungkus dalam JWT (Bearer Token)
        const token = jwt.sign(
            { id: user.id, role: user.role, random_key: customToken },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        res.json({
            message: 'Login berhasil',
            token: token, // Ini yang akan dikirim di header: Bearer <token>
            role: user.role
        });

    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

