const express = require('express');
const router = express.Router();
const resourceController = require('../controllers/resourceController');
const authMiddleware = require('../middlewares/authMiddleware'); // Import satpamnya

// Semua orang bisa melihat daftar barang
router.get('/', resourceController.getAllResources);
router.get('/:id', resourceController.getResourceById);

// HANYA yang punya Token (Admin) yang bisa menambah barang
// Ini memenuhi syarat "at least bearer token verification in 1 request"
router.post('/', authMiddleware, resourceController.createResource);

module.exports = router;