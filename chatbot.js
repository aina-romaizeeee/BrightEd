const express = require('express');
const redis = require('../redis');
const router = express.Router();

// POST /api/chatbot/message
router.post('/message', async (req, res) => {
  try {
    const { message } = req.body;
    const sessionKey = `chat:session`;

    // Get or init chat history from Redis (TTL: 30 min)
    const history = JSON.parse(await redis.get(sessionKey) || '[]');
    history.push({ role: 'user', content: message });

    // Mock bot reply — replace with your AI API call
    const reply = `Ed says: You asked "${message}". I'm here to help!`;
    history.push({ role: 'bot', content: reply });

    // Save updated history back to Redis
    await redis.setex(sessionKey, 1800, JSON.stringify(history));

    res.json({ reply });
  } catch (err) {
    res.status(500).json({ message: 'Chatbot error' });
  }
});

module.exports = router;