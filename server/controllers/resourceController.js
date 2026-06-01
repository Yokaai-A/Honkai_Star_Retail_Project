const db = require('../config/db');

// 1. Ambil SEMUA barang (Syarat GET ke-1)
exports.getAllResources = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM resources');
        res.json({
            status: 'success',
            data: rows
        });
    } catch (error) {
        res.status(500).json({ message: 'Gagal mengambil data', error: error.message });
    }
};

// 2. Ambil SATU barang berdasarkan ID (Syarat GET ke-2)
exports.getResourceById = async (req, res) => {
    const { id } = req.params;
    try {
        const [rows] = await db.execute('SELECT * FROM resources WHERE id = ?', [id]);
        if (rows.length === 0) {
            return res.status(404).json({ message: 'Barang tidak ditemukan' });
        }
        res.json({
            status: 'success',
            data: rows[0]
        });
    } catch (error) {
        res.status(500).json({ message: 'Gagal mengambil detail barang', error: error.message });
    }
};

// 3. Tambah barang baru (Syarat POST - Khusus Admin)
exports.createResource = async (req, res) => {
    const { name, type, description, stock, image, price } = req.body;

    // Validasi sederhana (Masuk dalam syarat "at least 3 validations")
    if (!name || !price || stock < 0) {
        return res.status(400).json({ message: 'Data tidak valid. Nama, harga, dan stok wajib benar.' });
    }

    try {
        const query = 'INSERT INTO resources (name, type, description, stock, image, price) VALUES (?, ?, ?, ?, ?, ?)';
        const values = [name, type, description, stock, image, price];

        await db.execute(query, values);
        res.status(201).json({ message: 'Barang berhasil ditambahkan ke Honkai Star Retail!' });
    } catch (error) {
        res.status(500).json({ message: 'Gagal menambah barang', error: error.message });
    }
};