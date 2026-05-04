const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const resourceRoutes = require('./routes/resourceRoutes');
const authRoutes = require('./routes/authRoutes');


dotenv.config();
const app = express();

app.use(cors());
app.use(express.json());

// Menggunakan Routes
app.use('/api/resources', resourceRoutes);

app.use('/api/auth', authRoutes);

app.get('/', (req, res) => {
    res.send('Server Honkai Star Retail berjalan!');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server aktif di http://localhost:${PORT}`);
});