// server/controllers/auth/AuthenticationChecker.js

const jwt = require('jsonwebtoken');
const jwtSecret = process.env.JWT_SECRET || 'your_jwt_secret_here';
const User = require('../../models/UserModel');
const Person = require('../../models/PersonModel');

async function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.sendStatus(401); // Unauthorized

  try {
    const decoded = jwt.verify(token, jwtSecret);
    const userId = decoded.userId; // Ensure your JWT payload includes userId

    // Fetch the user along with the associated Person
    const user = await User.findByPk(userId, {
      include: [{ model: Person }],
    });

    if (!user || !user.Person) {
      return res.status(404).json({ message: 'User or associated person not found' });
    }

    // Attach the user with Person to req.user
    req.user = user;
    next();
  } catch (err) {
    console.error('JWT Verification Error:', err);
    return res.sendStatus(403); // Forbidden
  }
}

module.exports = { authenticateToken };