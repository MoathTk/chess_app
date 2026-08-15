import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_app_v1/Models/solider.dart';
import 'package:chess_app_v1/Providers/board_provider.dart';
import 'package:chess_app_v1/Models/Game.dart';

// 1. Change to ConsumerWidget
class PieceCube extends ConsumerWidget {
  const PieceCube({
    super.key,
    required this.isWhite,
    required this.pieceIndex,
    required this.soliderType,
    required this.iconToDisplay,
    required this.turn,
    required this.currentGame,
  });

  final bool isWhite;
  final int pieceIndex;
  final SoliderType soliderType;
  final Icon iconToDisplay;
  final int turn;
  final Game currentGame;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(boardGameProvider(currentGame.gameID));
    final gameNotifier = ref.read(
      boardGameProvider(currentGame.gameID).notifier,
    );

    const Color lightSquare = Color.fromARGB(172, 255, 248, 220);

    const Color darkSquare = Color.fromARGB(255, 121, 102, 84);
    const Color prevous = Color.fromARGB(103, 180, 85, 48);
    const Color prevousOrNext = Color.fromARGB(192, 180, 85, 48);
    int highlightedPosition = gameState.placesToMove.contains(pieceIndex)
        ? 1
        : gameState.placesToKill.contains(pieceIndex)
        ? 2
        : 0;
    bool isTouched = gameState.currentTouchedIndex == pieceIndex;
    bool isPrvoius = gameState.movedFromIndex == pieceIndex;
    bool isNext = gameState.movedToIndex == pieceIndex;

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: InkWell(
            onTap: () {
              if (soliderType != SoliderType.none &&
                  gameState.currentTurn == turn) {
                if (gameState.currentTouchedIndex != pieceIndex) {
                  gameNotifier.convertCurrntIndex(pieceIndex);
                } else {
                  gameNotifier.convertCurrntIndex(-1);
                }
              } else {
                if (gameState.placesToMove.contains(pieceIndex)) {
                  gameNotifier.moveSolider(pieceIndex);
                } else if (gameState.placesToKill.contains(pieceIndex)) {
                  gameNotifier.killSoldier(pieceIndex);
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: (isPrvoius || isNext)
                    ? prevousOrNext
                    : isWhite
                    ? lightSquare
                    : darkSquare,
                border: Border.all(
                  color: isTouched
                      ? const Color.fromARGB(255, 105, 247, 110)
                      : Colors.transparent,
                  width: 2.0,
                ),
              ),
              child: Container(
                // decoration: BoxDecoration(
                //   gradient: RadialGradient(
                //     center: const Alignment(-0.8, -0.8),
                //     radius: 1.0,
                //     colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                //   ),
                // ),
                child: Center(child: iconToDisplay),
              ),
            ),
          ),
        ),
        if (highlightedPosition == 1)
          IgnorePointer(
            child: Center(
              child: AnimatedContainer(
                height: 8,
                width: 8,
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 160, 255, 178),
                  border: Border.all(width: 1.0),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        if (highlightedPosition == 2)
          IgnorePointer(
            child: AnimatedContainer(
              height: double.infinity,
              width: double.infinity,
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: const Color.fromARGB(131, 244, 67, 54),
                //border: Border.all(width: 1.0),
                //hape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
