// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../model/message.dart';

class MessengerSyncPage extends StatefulWidget {
  const MessengerSyncPage({super.key});

  @override
  State<MessengerSyncPage> createState() => _MessengerSyncPageState();
}

class _MessengerSyncPageState extends State<MessengerSyncPage>
    with TickerProviderStateMixin {
  late IO.Socket socket;
  List<Message> messages = [];
  bool isConnected = false;
  String connectionStatus = 'Disconnected';
  late AnimationController _connectionAnimationController;
  late Animation<double> _connectionAnimation;

  final String serverUrl = ''; // Update this with ngrok URL

  @override
  void initState() {
    super.initState();
    _connectionAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _connectionAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _connectionAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _connectToServer();
  }

  void _connectToServer() {
    try {
      socket = IO.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      socket.connect();

      socket.onConnect((_) {
        setState(() {
          isConnected = true;
          connectionStatus = 'Connected';
        });
        _connectionAnimationController.stop();
        print('Connected to server');
      });

      socket.onDisconnect((_) {
        setState(() {
          isConnected = false;
          connectionStatus = 'Disconnected';
        });
        _connectionAnimationController.repeat(reverse: true);
        print('Disconnected from server');
      });

      socket.on('connected', (data) {
        print('Server confirmed connection: ${data['message']}');
      });

      socket.on('new_message', (data) {
        final message = Message.fromJson(data);
        setState(() {
          messages.insert(0, message);
        });
        print('New message received: ${message.message}');
      });

      socket.onConnectError((error) {
        setState(() {
          connectionStatus = 'Connection Error';
        });
        _connectionAnimationController.repeat(reverse: true);
        print('Connection error: $error');
      });
    } catch (e) {
      setState(() {
        connectionStatus = 'Error: $e';
      });
      _connectionAnimationController.repeat(reverse: true);
      print('Socket initialization error: $e');
    }
  }

  void _reconnect() {
    socket.disconnect();
    setState(() {
      connectionStatus = 'Reconnecting...';
    });
    _connectionAnimationController.repeat(reverse: true);
    _connectToServer();
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'messenger':
        return const Color(0xFF0084FF);
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'telegram':
        return const Color(0xFF0088CC);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  void dispose() {
    _connectionAnimationController.dispose();
    socket.disconnect();
    super.dispose();
  }

  Widget _buildMessageBubble(Message message) {
    final platformColor = _getPlatformColor(message.platform);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Platform indicator dot
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 8, right: 16),
            decoration: BoxDecoration(
              color: platformColor,
              shape: BoxShape.circle,
            ),
          ),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with sender and platform
                Row(
                  children: [
                    Text(
                      message.senderId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: platformColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        message.platform.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: platformColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Message bubble
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    message.message,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF374151),
                      height: 1.4,
                    ),
                  ),
                ),

                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_formatDate(message.timestamp)} • ${_formatTime(message.timestamp)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 32,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Messages from connected platforms will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Row(
          children: [
            // Connection indicator
            AnimatedBuilder(
              animation: _connectionAnimation,
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color:
                        isConnected
                            ? const Color(0xFF10B981)
                            : Color(
                              0xFFEF4444,
                            ).withOpacity(_connectionAnimation.value),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
            const Text(
              'Chat Bridge',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6B7280)),
            onPressed: _reconnect,
            tooltip: 'Reconnect',
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF6B7280)),
                        SizedBox(width: 8),
                        Text(
                          'Connection Info',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildInfoRow(
                          'Server',
                          serverUrl.isEmpty ? 'Not configured' : serverUrl,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          'Status',
                          connectionStatus,
                          statusColor:
                              isConnected
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Messages', '${messages.length}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: 'Connection Info',
            icon: const Icon(Icons.info_outline, color: Color(0xFF6B7280)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Minimalistic status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.circle : Icons.circle_outlined,
                  color:
                      isConnected
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                  size: 12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    connectionStatus,
                    style: TextStyle(
                      color:
                          isConnected
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (messages.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${messages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child:
                messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? statusColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: statusColor ?? const Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
