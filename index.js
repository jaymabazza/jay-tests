const express = require('express');
const app = express();

const secret = process.env.WEBHOOK_SECRET;
if (!secret) {
  console.warn("WARNING: WEBHOOK_SECRET is not set. Running in insecure mode.");
}

// 1. You MUST read the PORT from the environment variable
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

// 2. You MUST listen on '0.0.0.0' (not localhost/127.0.0.1)
app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});