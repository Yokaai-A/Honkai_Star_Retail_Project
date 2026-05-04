const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
    // 1. Ambil token dari header 'Authorization'
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Format: Bearer <token>

    if (!token) {
        return res.status(401).json({ message: 'Akses ditolak, token tidak ditemukan' });
    }

    try {
        // 2. Verifikasi token
        const verified = jwt.verify(token, process.env.JWT_SECRET);
        req.user = verified; // Menyimpan data user (id, role) ke request
        next(); // Lanjut ke fungsi controller
    } catch (err) {
        res.status(403).json({ message: 'Token tidak valid atau kadaluwarsa' });
    }
};