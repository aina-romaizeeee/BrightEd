const redis = require('redis');

// Create client
const client = redis.createClient({
  url: 'redis://localhost:6379', // adjust if using Docker or remote
});

client.on('error', (err) => console.error('Redis error:', err));
client.connect();

module.exports = client;
