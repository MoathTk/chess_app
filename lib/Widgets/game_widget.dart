import 'package:chess_app_v1/Screens/board_ui.dart';

import 'package:flutter/material.dart';
import 'package:chess_app_v1/Models/Game.dart';
import 'package:chess_app_v1/Backend/date.dart';

class GameWidget extends StatelessWidget {
  const GameWidget({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 1. Left Accent Bar (Visual flair)
              Container(
                width: 6,
                color: game.winner == -1 ? Colors.blueAccent : Colors.grey,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row with Game ID and Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "GAME #${game.gameID}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.blueAccent[700],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            Date.convertToReadableTime(game.dateOfStart),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Matchup Section
                      Row(
                        children: [
                          _buildPlayerAvatar('P1'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              game.playerOne.playerTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "VS",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              game.playerTwo.playerTitle,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildPlayerAvatar('P2'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Action Arrow
              Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: IconButton(
                  onPressed: () async {
                    // Inside your button's onPressed
                    if (game == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameBoard(
                          player1Name: game.playerOneTitle,
                          player2Name: game.playerTwoTitle,
                          currentGame: game,
                        ),
                      ),
                    );
                    // ChessDb.saveAllChanges(game);
                  },
                  icon: Icon(Icons.chevron_right),
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerAvatar(String label) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: Colors.grey[200],
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }
}
