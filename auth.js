// start docker
const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const redis = require('../redis');
const router = express.Router();

// Mock users database
const MOCK_USERS = [
  {
    id: '1',
    name: 'Admin User',
    username: 'admin@test.com',
    email: 'admin@test.com',
    role: 'admin',
    password: bcrypt.hashSync('password123', 10),
  },
  {
    id: '2',
    name: 'Teacher One',
    username: 'teacher@test.com',
    email: 'teacher@test.com',
    role: 'teacher',
    password: bcrypt.hashSync('password123', 10),
  },
  {
    id: '3',
    name: 'Student One',
    username: 'student@test.com',
    email: 'student@test.com',
    role: 'student',
    password: bcrypt.hashSync('password123', 10),
  },
];

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ message: 'Username and password are required' });
    }

    const user = MOCK_USERS.find(
      (u) => u.username === username || u.email === username
    );

    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isValidPassword = bcrypt.compareSync(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET || 'fallback-secret-key',
      { expiresIn: '1h' }
    );

    await redis.setex(`token:${user.id}`, 3600, token);

    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        username: user.username,
        email: user.email,
        role: user.role,
      },
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

// POST /api/auth/logout
router.post('/logout', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader) {
      const token = authHeader.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback-secret-key');
      await redis.del(`token:${decoded.id}`);
    }
    res.json({ message: 'Logged out successfully' });
  } catch (err) {
    res.json({ message: 'Logged out' });
  }
});

// Middleware to verify token
const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ message: 'No token provided' });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback-secret-key');
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(403).json({ message: 'Invalid token' });
  }
};

module.exports = { router, authenticateToken };