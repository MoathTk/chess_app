import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import 'package:chess_app_v1/Models/solider.dart';
import 'package:chess_app_v1/Models/Game.dart';
import 'package:chess_app_v1/Providers/board_provider.dart';

class PromotionDialog extends ConsumerWidget {
  final Color pieceColor;
  final Game game;

  const PromotionDialog({
    super.key,
    required this.pieceColor,
    required this.game,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the provider once here
    final gameBoard = ref.read(boardGameProvider(game.gameID).notifier);

    return BackdropFilter(
      // This creates the frosted glass effect on the background board
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: AlertDialog(
        backgroundColor: const Color.fromARGB(
          220,
          30,
          30,
          30,
        ), // Slightly more opaque for readability
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Pawn Promotion",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize
              .min, // CRITICAL: Makes the dialog stay centered and small
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _promotionOption(
                  context,
                  MdiIcons.chessQueen,
                  SoliderType.queen,
                  gameBoard,
                ),
                _promotionOption(
                  context,
                  MdiIcons.chessRook,
                  SoliderType.rock,
                  gameBoard,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _promotionOption(
                  context,
                  MdiIcons.chessBishop,
                  SoliderType.bishop,
                  gameBoard,
                ),
                _promotionOption(
                  context,
                  MdiIcons.chessKnight,
                  SoliderType.knight,
                  gameBoard,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _promotionOption(
    BuildContext context,
    IconData icon,
    SoliderType type,
    dynamic gameBoard, // Passing the notifier directly
  ) {
    return GestureDetector(
      onTap: () async {
        // 1. Update the piece in the database/provider
        await gameBoard.promotePawnInDatabase(type);

        
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, size: 50, color: pieceColor),
      ),
    );
  }
}
