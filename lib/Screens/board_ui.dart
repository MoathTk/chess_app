import 'package:chess_app_v1/Providers/board_provider.dart';
import 'package:chess_app_v1/Backend/chess_clock.dart';
import 'package:chess_app_v1/Screens/promotion_screen.dart';
import 'package:chess_app_v1/DataBase/chess_db.dart' as db;
import 'package:chess_app_v1/Screens/game_screen.dart'; // for the shared games list
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chess_app_v1/Models/Game.dart';
import 'package:chess_app_v1/Models/solider.dart';
import 'package:chess_app_v1/Widgets/piece_cube.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:chess_app_v1/Widgets/killed_piece_widget.dart';
import 'package:chess_app_v1/Screens/endgame_screen.dart'; // Contains WinnerDialog

class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({
    super.key,
    required this.player1Name,
    required this.player2Name,
    required this.currentGame,
  });

  final String player1Name;
  final String player2Name;
  final Game currentGame;

  @override
  ConsumerState<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard> {
  // Tracks the last winner we already announced so the endgame dialog shows
  // exactly once. Kept as widget state because every GameBoardState in the
  // provider shares the same mutable Game object, so comparing winners between
  // provider states cannot detect a transition.
  int _announcedWinner = -1;

  // ✅ EDITION: Moved triggerGameOver out of the build method to the class scope
  void triggerGameOver(String winnerName, bool isWhiteWinner,
      {String resultLabel = "CHECKMATE"}) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an option
      builder: (BuildContext dialogContext) {
        return WinnerDialog(
          winnerName: winnerName,
          isWhiteWinner: isWhiteWinner,
          resultLabel: resultLabel,
          onRematch: () {
            // Close the dialog, then start a fresh game with the same players.
            Navigator.of(dialogContext).pop();
            _startRematch();
          },
          onHome: () {
            // Close the dialog and return to the games list.
            Navigator.of(dialogContext).pop();
            _goHome();
          },
        );
      },
    );
  }

  // Starts a brand new match with the same players, mode and time control,
  // replacing the current finished board with the fresh one.
  Future<void> _startRematch() async {
    int newGameID = await Game.addNewGame(
      widget.player1Name,
      widget.player2Name,
      widget.currentGame.mode == 1,
      widget.currentGame.timeControlMinutes,
      widget.currentGame.timeControlMinutes,
    );

    // Keep the shared games list in sync so the new game can be opened.
    games
      ..clear()
      ..addAll(await db.ChessDb.getAllUserGames());

    if (!mounted) return;

    Game newGame = games.firstWhere((g) => g.gameID == newGameID);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameBoard(
          player1Name: widget.player1Name,
          player2Name: widget.player2Name,
          currentGame: newGame,
        ),
      ),
    );
  }

  // Returns to the games list (the home screen of the app).
  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final provider = boardGameProvider(widget.currentGame.gameID);
    final gameState = ref.watch(provider);
    final gameBoard = ref.watch(provider.notifier);

    // ✅ EDITION: Safely listening for endgame state side-effects using ref.listen
    ref.listen(provider, (previous, next) {
      int winner = next.board.game.winner;
      // Show the dialog the first time a decided winner is seen (0 =
      // playerOne/white, 1 = playerTwo/black), regardless of the previous
      // provider state, which shares the same mutable Game object.
      if ((winner == 0 || winner == 1) && winner != _announcedWinner) {
        _announcedWinner = winner;
        bool isWhiteWinner = winner == 0;
        String winnerName = isWhiteWinner
            ? widget.player1Name
            : widget.player2Name;

        triggerGameOver(
          winnerName,
          isWhiteWinner,
          resultLabel: gameBoard.timedOut ? "WON ON TIME" : "CHECKMATE",
        );
      }
    });

    const Color boardBorder = Color.fromARGB(255, 133, 119, 114);

    bool turn = gameState.board.game.playerOne.turn;
    bool isPlayer1Turn = turn;
    bool isPlayer2Turn = !turn;

    Icon setIcon(SoliderType type, bool isWhite) {
      final IconData iconData = switch (type) {
        SoliderType.king => MdiIcons.chessKing,
        SoliderType.queen => MdiIcons.chessQueen,
        SoliderType.knight => MdiIcons.chessKnight,
        SoliderType.rock => MdiIcons.chessRook,
        SoliderType.bishop => MdiIcons.chessBishop,
        SoliderType.pawn => MdiIcons.chessPawn,
        SoliderType.none => MdiIcons.abTesting,
      };
      return Icon(
        iconData,
        size: 45,
        color: type != SoliderType.none
            ? (isWhite ? Colors.white : Colors.black)
            : Colors.transparent,
      );
    }

    int promotable = gameBoard.hasToPromotePawn();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text("Match #1024", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: promotable == -1
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KilledPieceWidget(
                      playerID: gameState.board.game.playerOne.id,
                      gameID: gameState.board.game.gameID,
                      isWhite: true,
                    ),
                    _buildPlayerInfo(
                      name: widget.player1Name,
                      rating: "2100",
                      avatarColor: Colors.orangeAccent,
                      isOpponent: true,
                      isActiveTurn: isPlayer1Turn,
                      timeLeft:
                          gameState.board.game.playerOne.remainingTime,
                    ),
                    const SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        child: ClipRRect(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 8,
                                ),
                            itemCount: 64,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              int row = index ~/ 8;
                              int col = index % 8;
                              bool isSquareWhite = (row + col) % 2 == 0;

                              var piece = gameState.board
                                  .getChessBoardList()[index];

                              SoliderType type = piece.soliderType;
                              bool isWhitePiece =
                                  piece.playerID ==
                                  widget.currentGame.playerOne.id;

                              return PieceCube(
                                isWhite: isSquareWhite,
                                iconToDisplay: setIcon(type, isWhitePiece),
                                currentGame: widget.currentGame,
                                pieceIndex: index,
                                soliderType: piece.soliderposition == -1
                                    ? SoliderType.none
                                    : type,
                                turn: type == SoliderType.none
                                    ? -1
                                    : (isWhitePiece ? 0 : 1),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPlayerInfo(
                      name: widget.player2Name,
                      rating: "1550",
                      avatarColor: Colors.blueAccent,
                      isOpponent: false,
                      isActiveTurn: isPlayer2Turn,
                      timeLeft:
                          gameState.board.game.playerTwo.remainingTime,
                    ),
                    KilledPieceWidget(
                      playerID: gameState.board.game.playerTwo.id,
                      gameID: gameState.board.game.gameID,
                      isWhite: false,
                    ),
                    // ✅ EDITION: Removed the inline WinnerDialog block from here
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        KilledPieceWidget(
                          playerID: gameState.board.game.playerOne.id,
                          gameID: gameState.board.game.gameID,
                          isWhite: true,
                        ),
                        _buildPlayerInfo(
                          name: widget.player1Name,
                          rating: "2100",
                          avatarColor: Colors.orangeAccent,
                          isOpponent: true,
                          isActiveTurn: isPlayer1Turn,
                          timeLeft:
                              gameState.board.game.playerOne.remainingTime,
                        ),
                        const SizedBox(height: 20),
                        AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: boardBorder,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: boardBorder, width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8,
                                    ),
                                itemCount: 64,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  int row = index ~/ 8;
                                  int col = index % 8;
                                  bool isSquareWhite = (row + col) % 2 == 0;

                                  var piece = gameState.board
                                      .getChessBoardList()[index];

                                  SoliderType type = piece.soliderType;
                                  bool isWhitePiece =
                                      piece.playerID ==
                                      widget.currentGame.playerOne.id;

                                  return PieceCube(
                                    isWhite: isSquareWhite,
                                    iconToDisplay: setIcon(type, isWhitePiece),
                                    currentGame: widget.currentGame,
                                    pieceIndex: index,
                                    soliderType: piece.soliderposition == -1
                                        ? SoliderType.none
                                        : type,
                                    turn: type == SoliderType.none
                                        ? -1
                                        : (isWhitePiece ? 0 : 1),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildPlayerInfo(
                          name: widget.player2Name,
                          rating: "1550",
                          avatarColor: Colors.blueAccent,
                          isOpponent: false,
                          isActiveTurn: isPlayer2Turn,
                          timeLeft:
                              gameState.board.game.playerTwo.remainingTime,
                        ),
                        KilledPieceWidget(
                          playerID: gameState.board.game.playerTwo.id,
                          gameID: gameState.board.game.gameID,
                          isWhite: false,
                        ),
                      ],
                    ),
                  ),
                ),
                PromotionDialog(
                  pieceColor: promotable == 1 ? Colors.white : Colors.black,
                  game: widget.currentGame,
                ),
              ],
            ),
    );
  }
}

// --- Helper UI Widgets ---

Widget _buildPlayerInfo({
  required String name,
  required String rating,
  required Color avatarColor,
  required bool isOpponent,
  required bool isActiveTurn,
  required int timeLeft,
}) {
  return Row(
    mainAxisAlignment: isOpponent
        ? MainAxisAlignment.start
        : MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      if (isOpponent) ...[
        _buildAvatar(avatarColor, isActiveTurn),
        const SizedBox(width: 12),
      ],

      Column(
        crossAxisAlignment: isOpponent
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isOpponent && isActiveTurn) ...[
                _buildTurnBadge(),
                const SizedBox(width: 8),
              ],
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
              if (isOpponent && isActiveTurn) ...[
                const SizedBox(width: 8),
                _buildTurnBadge(),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Rating: $rating",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              if (timeLeft > 0) ...[
                const SizedBox(width: 8),
                _buildClock(timeLeft),
              ],
            ],
          ),
        ],
      ),

      if (!isOpponent) ...[
        const SizedBox(width: 12),
        _buildAvatar(avatarColor, isActiveTurn),
      ],
    ],
  );
}

// Renders the player's countdown clock ("mm:ss"). Turns red when the player
// is low on time (<= 30s) so it reads as urgent, chess.com style.
Widget _buildClock(int seconds) {
  final bool low = ChessClock.isLowTime(seconds);
  final Color color = low ? Colors.redAccent : Colors.white;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(
      color: low ? Colors.redAccent.withValues(alpha: 0.15) : Colors.white10,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: 0.6)),
      boxShadow: low
          ? [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ]
          : null,
    ),
    child: Text(
      ChessClock.formatTime(seconds),
      style: TextStyle(
        color: color,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: 1,
      ),
    ),
  );
}

Widget _buildTurnBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.greenAccent.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
      boxShadow: [
        BoxShadow(
          color: Colors.greenAccent.withValues(alpha: 0.1),
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ],
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: Colors.greenAccent, size: 8),
        SizedBox(width: 4),
        Text(
          "THINKING",
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );
}

Widget _buildAvatar(Color color, bool isActiveTurn) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    width: isActiveTurn ? 54 : 48,
    height: isActiveTurn ? 54 : 48,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(
        color: isActiveTurn ? Colors.greenAccent : Colors.white24,
        width: isActiveTurn ? 2.5 : 2,
      ),
      boxShadow: isActiveTurn
          ? [
              BoxShadow(
                color: Colors.greenAccent.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ]
          : const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
    ),
    child: const Icon(Icons.person, color: Colors.white),
  );
}
