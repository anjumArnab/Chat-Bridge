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
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const MessengerSyncPage(),
    );
  }
}
