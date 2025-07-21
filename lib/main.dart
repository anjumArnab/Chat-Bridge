import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../views/messenger_sync_page.dart';

void main() {
  runApp(const ChatBridge());
}

class ChatBridge extends StatelessWidget {
  const ChatBridge({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Bridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 1,
          shadowColor: Colors.black12,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const MessengerSyncPage(),
    );
  }
}
