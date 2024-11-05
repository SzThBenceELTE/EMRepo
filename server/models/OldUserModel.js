const sqlite3 = require('better-sqlite3');
const db = new sqlite3('database.db');

// Create users table if it doesn't exist
db.prepare(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    email TEXT
  )
`).run();

const User = {
  getAll: () => db.prepare('SELECT * FROM users').all(),
  create: (name, email) => db.prepare('INSERT INTO users (name, email) VALUES (?, ?)').run(name, email),
  findById: (id) => db.prepare('SELECT * FROM users WHERE id = ?').get(id),
  update: (id, name, email) => db.prepare('UPDATE users SET name = ?, email = ? WHERE id = ?').run(name, email, id),
  delete: (id) => db.prepare('DELETE FROM users WHERE id = ?').run(id)
};

module.exports = User;