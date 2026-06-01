const db = require('./config/db');
const bcrypt = require('bcryptjs');

async function init() {
  try {
    console.log("Initializing database with default data...");

    // 1. Clear existing data to avoid duplicates
    await db.query("DELETE FROM users");
    await db.query("DELETE FROM resources");

    // 2. Insert Users
    const hashedAdminPassword = await bcrypt.hash('admin123', 10);
    const hashedUserPassword = await bcrypt.hash('user123', 10);

    await db.query(
      "INSERT INTO users (username, password, role) VALUES (?, ?, ?), (?, ?, ?)",
      ['admin', hashedAdminPassword, 'admin', 'user', hashedUserPassword, 'user']
    );
    console.log("Default users created successfully!");

    // 3. Insert Resources
    const resources = [
      [
        'Before Dawn', 
        'Light Cone', 
        'A high-frequency Light Cone that stores the combat memory of the Divine Foresight. Greatly increases the wearer\'s Critical Damage and follow-up skill output. Powered by path energy.',
        0, 
        'assets/images/beforeDawn.jpg', 
        1280.0
      ],
      [
        'Perfect Timing', 
        'Light Cone', 
        'A Light Cone recording a frozen moment. It portrays Luocha treating a patient. Increases the wearer\'s Effect Resistance and outgoing healing capacity based on their mental focus.',
        15, 
        'assets/images/perfectTiming.jpg', 
        480.0
      ],
      [
        'Star Rail Pass', 
        'Ticket', 
        'A ticket required to warp aboard the Astral Express. Emits a subtle cosmic hum, containing the coordinates of distant stellar systems.',
        50, 
        'assets/images/starRailPass.jpg', 
        160.0
      ],
      [
        'Tracks of Destiny', 
        'Material', 
        'A rare catalyst obtained from the memories of the universe. Crucial for tracing the path of Destinies and leveling up high-tier combat abilities.',
        5, 
        'assets/images/tracksOfDestiny.jpg', 
        50000.0
      ]
    ];

    for (let r of resources) {
      await db.query(
        "INSERT INTO resources (name, type, description, stock, image, price) VALUES (?, ?, ?, ?, ?, ?)",
        r
      );
    }
    console.log("Default resources populated successfully!");

  } catch (err) {
    console.error("Initialization failed:", err.message);
  } finally {
    process.exit(0);
  }
}

init();
