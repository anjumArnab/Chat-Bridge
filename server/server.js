const express = require('express');
const { Server } = require('socket.io');
const http = require('http');
const cors = require('cors');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Facebook Messenger Configuration
const VERIFY_TOKEN = '';
const PAGE_ACCESS_TOKEN = '';

// Store connected Flutter clients
const connectedClients = new Set();

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('Flutter client connected:', socket.id);
  connectedClients.add(socket.id);

  socket.on('disconnect', () => {
    console.log('Flutter client disconnected:', socket.id);
    connectedClients.delete(socket.id);
  });

  // Send connection confirmation
  socket.emit('connected', { message: 'Connected to server' });
});

// Facebook Webhook Verification
app.get('/webhook', (req, res) => {
  const mode = req.query['hub.mode'];
  const token = req.query['hub.verify_token'];
  const challenge = req.query['hub.challenge'];

  if (mode === 'subscribe' && token === VERIFY_TOKEN) {
    console.log('Webhook verified successfully');
    res.status(200).send(challenge);
  } else {
    console.log('Webhook verification failed');
    res.status(403).send('Forbidden');
  }
});

// Facebook Webhook - Receive Messages
app.post('/webhook', (req, res) => {
  const body = req.body;

  if (body.object === 'page') {
    body.entry.forEach((entry) => {
      const webhookEvent = entry.messaging[0];
      
      if (webhookEvent.message) {
        handleMessage(webhookEvent);
      }
    });

    res.status(200).send('EVENT_RECEIVED');
  } else {
    res.status(404).send('Not Found');
  }
});

// Handle incoming messages from Messenger
function handleMessage(event) {
  const senderId = event.sender.id;
  const messageText = event.message.text;
  const timestamp = event.timestamp;

  console.log(`Received message from ${senderId}: ${messageText}`);

  // Create message object
  const messageData = {
    id: `${senderId}_${timestamp}`,
    senderId: senderId,
    message: messageText,
    timestamp: new Date(timestamp),
    platform: 'messenger'
  };

  // Send message to all connected Flutter clients
  io.emit('new_message', messageData);

  // Optional: Send auto-reply back to Messenger
  sendMessengerReply(senderId, `Echo: ${messageText}`);
}

// Send reply back to Messenger (optional)
function sendMessengerReply(recipientId, messageText) {
  const messageData = {
    recipient: {
      id: recipientId
    },
    message: {
      text: messageText
    }
  };

  fetch(`https://graph.facebook.com/v18.0/me/messages?access_token=${PAGE_ACCESS_TOKEN}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(messageData)
  })
  .then(response => response.json())
  .then(data => console.log('Reply sent:', data))
  .catch(error => console.error('Error sending reply:', error));
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    connectedClients: connectedClients.size,
    timestamp: new Date().toISOString()
  });
});

// Test endpoint to simulate message (for development)
app.post('/test-message', (req, res) => {
  const { message, senderId } = req.body;
  
  const testMessage = {
    id: `test_${Date.now()}`,
    senderId: senderId || 'test_user',
    message: message || 'Test message',
    timestamp: new Date(),
    platform: 'test'
  };

  io.emit('new_message', testMessage);
  res.json({ success: true, message: 'Test message sent' });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Webhook URL: http://localhost:${PORT}/webhook`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});