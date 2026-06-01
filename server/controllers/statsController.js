const db = require('../config/db');

// GET /api/stats – statistik untuk admin dashboard
exports.getStats = async (req, res) => {
    try {
        const [[{ totalUsers }]] = await db.execute('SELECT COUNT(*) AS totalUsers FROM users');
        const [[{ totalResources }]] = await db.execute('SELECT COUNT(*) AS totalResources FROM resources');
        const [[{ totalTransactions }]] = await db.execute('SELECT COUNT(*) AS totalTransactions FROM transactions');

        res.json({
            status: 'success',
            data: {
                totalUsers,
                totalResources,
                totalTransactions,
            }
        });
    } catch (error) {
        res.status(500).json({ message: 'Gagal mengambil statistik', error: error.message });
    }
};
