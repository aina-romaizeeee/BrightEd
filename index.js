const express = require('express');
const cors = require('cors');
const redis = require('./redis');
const authRoutes = require('./routes/auth');
const chatbotRoutes = require('./routes/chatbot');

const app = express();
app.use(cors());
app.use(express.json());

// Health check with Redis ping
app.get('/health', async (req, res) => {
  try {
    const ping = await redis.ping();
    res.json({ status: 'ok', redis: ping });
  } catch (err) {
    res.status(500).json({ status: 'error', redis: 'down' });
  }
});

app.use('/api/auth', authRoutes);
app.use('/api/chatbot', chatbotRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));