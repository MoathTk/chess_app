
import 'package:chess_app_v1/Models/solider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_app_v1/Providers/board_provider.dart';
import 'package:chess_app_v1/Models/player.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class KilledPieceRetreiveWidget extends ConsumerWidget {
  const KilledPieceRetreiveWidget({
    super.key,
    required this.playerColor,
    required this.playerID,
    required this.gameID,
  });

  final int playerID;
  final int gameID;
  final ColorType playerColor;

  // Helper method to get the correct icon
  IconData _getPieceIcon(SoliderType type) {
    return switch (type) {
      SoliderType.king => MdiIcons.chessKing,
      SoliderType.queen => MdiIcons.chessQueen,
      SoliderType.knight => MdiIcons.chessKnight,
      SoliderType.rock => MdiIcons.chessRook, // Kept your 'rock' spelling
      SoliderType.bishop => MdiIcons.chessBishop,
      SoliderType.pawn => MdiIcons.chessPawn,
      SoliderType.none => MdiIcons.helpBox,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(boardGameProvider(gameID));
    List<Solider> killedSoldiers = gameState.board.getPlayerkilledSoldiers(playerID);
    
    // Determine the color of the pieces based on the player's team
    final bool isWhite = playerColor == ColorType.white;
    final pieceColor = isWhite ? Colors.white : Colors.black87;
    final pieceShadow = isWhite ? Colors.black26 : Colors.white24;

    return Container(
      width: 200,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.grey.shade800, // A sleek, dark professional background
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Header Area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(
              child: Text(
                "Graveyard", // Or "Promote to:"
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          
          // 2. Grid or Empty State
          Expanded(
            child: killedSoldiers.isEmpty
                ? const Center(
                    child: Text(
                      "No pieces captured yet",
                      style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
                    ),
                  )
                : _killedSoldiersGrid(killedSoldiers, pieceColor, pieceShadow),
          ),
        ],
      ),
    );
  }

  // 3. The 2-Column Grid Builder
  Widget _killedSoldiersGrid(List<Solider> pieces, Color pieceColor, Color shadowColor) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 items per row
        crossAxisSpacing: 12, // Space between columns
        mainAxisSpacing: 12, // Space between rows
        childAspectRatio: 1.0, // Perfect squares
      ),
      itemCount: pieces.length,
      itemBuilder: (context, index) {
        final piece = pieces[index];
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade600, width: 1),
              ),
              child: Center(
                child: Icon(
                  _getPieceIcon(piece.soliderType),
                  size: 38,
                  color: pieceColor,
                  shadows: [
                    Shadow(
                      color: shadowColor,
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}