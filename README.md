# Chat Bridge

A Flutter application integrated with a Node.js server that receives Facebook Messenger messages via webhooks and forwards them to Flutter clients in real-time using Socket.IO

## 📋 Prerequisites

- Node.js (v16 or higher)
- npm or yarn
- Facebook Developer Account
- Facebook Page
- ngrok (for local development)

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/messenger-flutter-sync-backend.git
   cd messenger-flutter-sync-backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the root directory:
   ```env
   # Server Configuration
   PORT=3000
   
   # Facebook Messenger Configuration
   VERIFY_TOKEN=your_secure_verify_token_here
   PAGE_ACCESS_TOKEN=your_facebook_page_access_token_here


## 🔧 Configuration

### Facebook App Setup

1. **Create a Facebook App**
   - Go to [Facebook Developers](https://developers.facebook.com/)
   - Create a new app with "Business" type
   - Note your App ID

2. **Add Messenger Product**
   - In your app dashboard, add the Messenger product
   - Set up webhooks with your ngrok URL

3. **Configure Webhook**
   - **Callback URL**: `https://your-ngrok-url.ngrok.io/webhook`
   - **Verify Token**: Use the same token as in your `.env` file
   - **Subscribe to**: `messages`, `messaging_postbacks`

4. **Generate Page Access Token**
   - Connect your Facebook Page
   - Copy the generated Page Access Token to your `.env` file

### Server Configuration

Update the configuration in `server.js` if not using environment variables:

```javascript
const VERIFY_TOKEN = process.env.VERIFY_TOKEN || 'your_verify_token_here';
const PAGE_ACCESS_TOKEN = process.env.PAGE_ACCESS_TOKEN || 'your_page_access_token_here';
```

## 🚀 Usage

### Development Mode

1. **Start the server with auto-reload**
   ```bash
   npm run dev
   ```

2. **Expose local server using ngrok**
   ```bash
   ngrok http 3000
   ```

3. **Update Facebook webhook URL** with your ngrok HTTPS URL

### Production Mode

```bash
npm start
```

## 📡 API Endpoints

### Webhook Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/webhook` | Webhook verification for Facebook |
| POST | `/webhook` | Receive messages from Facebook Messenger |

### Utility Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check and server status |
| POST | `/test-message` | Send test message to connected clients |

### Health Check Response

```json
{
  "status": "OK",
  "connectedClients": 2,
  "timestamp": "2025-07-21T10:30:00.000Z"
}
```

### Test Message Request

```json
{
  "message": "Hello from test!",
  "senderId": "test_user_123"
}
```

## 🔄 Socket.IO Events

### Server Events (Emitted by Server)

| Event | Description | Payload |
|-------|-------------|---------|
| `connected` | Connection confirmation | `{ message: 'Connected to server' }` |
| `new_message` | New message from Messenger | Message Object |

### Message Object Structure

```json
{
  "id": "unique_message_id",
  "senderId": "messenger_user_id",
  "message": "Hello, this is a message!",
  "timestamp": "2025-07-21T10:30:00.000Z",
  "platform": "messenger"
}
```

## 📱 Flutter Integration Example

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MessengerSyncService {
  late IO.Socket socket;

  void connectToServer() {
    socket = IO.io('http://your-server-url:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.on('connected', (data) {
      print('Connected to server: ${data['message']}');
    });

    socket.on('new_message', (data) {
      handleNewMessage(data);
    });
  }

  void handleNewMessage(dynamic data) {
    // Process incoming message
    print('New message: ${data['message']} from ${data['senderId']}');
  }

  void disconnect() {
    socket.disconnect();
  }
}
```

## 🧪 Testing

### Test Message Sending

Send a POST request to `/test-message`:

```bash
curl -X POST http://localhost:3000/test-message \
  -H "Content-Type: application/json" \
  -d '{"message": "Test message", "senderId": "test_user"}'
```

## 🌐 Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `PORT` | Server port (default: 3000) | No |
| `VERIFY_TOKEN` | Facebook webhook verify token | Yes |
| `PAGE_ACCESS_TOKEN` | Facebook page access token | Yes |
| `NODE_ENV` | Environment (development/production) | No |
