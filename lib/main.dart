import 'package:flutter/material.dart';
import 'package:chess_app_v1/Screens/game_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//king checked for ever.
//winner detetmiantion.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // db.ChessDb.deleteMyDatabase();
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // optional
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              "YOUR GAMES",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          backgroundColor: Colors.white,
          body: GamesScreen(),
        ),
      ),
    );
  }
}
