import 'package:flutter_test/flutter_test.dart';

import 'package:chess_app_v1/Backend/check_logic.dart';
import 'package:chess_app_v1/Backend/computer_logic.dart';
import 'package:chess_app_v1/Models/Game.dart';
import 'package:chess_app_v1/Models/board.dart';
import 'package:chess_app_v1/Models/computer_turn.dart';
import 'package:chess_app_v1/Models/player.dart';
import 'package:chess_app_v1/Models/solider.dart';

// The random computer opponent must never propose an illegal move: whatever it
// picks must pass the same king-safety validation the human move executor uses
// (so the move will actually be accepted). And when the side is checkmated it
// must return null (game over) instead of a bogus move.
void main() {
  test('random AI returns a legal move for the side to play', () {
    for (int sample = 0; sample < 50; sample++) {
      Board board = _buildKingsAndRookBoard();
      Player side = board.game.playerTwo; // black to play, rook + king white

      ComputerTurn? turn = ComputerLogic.determineAll(board, side);
      expect(turn, isNotNull, reason: 'black must have a legal move');

      bool isKill = turn!.type;

      if (isKill) {
        expect(
          CheckLogic.willNotKillCauseCheckedKingOrAboutToBeKilled(
            turn.currentSoldier.soliderposition,
            turn.where,
            side.id,
            false,
            board.clone(),
          ),
          true,
        );
      } else {
        expect(
          CheckLogic.willMoveCauseCheckedKing(
            turn.currentSoldier.soliderposition,
            turn.where,
            side.id,
            false,
            board.clone(),
          ),
          true,
        );
      }
    }
  });

  test('random AI returns no move when the side is checkmated', () {
    // Reuse the guarded-checker mate from checkmate_guarded_checker_test:
    // black king at 60 is mated by white rooks.
    Player playerOne = Player(
      id: 0,
      playerTitle: 'White',
      color: ColorType.white,
      turn: true,
      promotable: -1,
      remainingTime: 0,
      king: Solider(
        soliderID: 1,
        soliderType: SoliderType.king,
        soliderposition: 4,
        playerID: 0,
        firstMove: false,
      ),
      queen: [],
      pawns: [],
      horses: [],
      bishops: [],
      rooks: [
        Solider(
          soliderID: 100,
          soliderType: SoliderType.rock,
          soliderposition: 52,
          playerID: 0,
          firstMove: false,
          checker: true,
        ),
        Solider(
          soliderID: 101,
          soliderType: SoliderType.rock,
          soliderposition: 53,
          playerID: 0,
          firstMove: false,
        ),
        Solider(
          soliderID: 102,
          soliderType: SoliderType.rock,
          soliderposition: 51,
          playerID: 0,
          firstMove: false,
        ),
      ],
    );

    Player playerTwo = Player(
      id: 1,
      playerTitle: 'Black',
      color: ColorType.black,
      turn: false,
      promotable: -1,
      remainingTime: 0,
      king: Solider(
        soliderID: 2,
        soliderType: SoliderType.king,
        soliderposition: 60,
        playerID: 1,
        firstMove: false,
      ),
      queen: [],
      pawns: [],
      horses: [],
      bishops: [],
      rooks: [],
    );

    Game game = Game(
      gameID: 999,
      playerOne: playerOne,
      playerTwo: playerTwo,
      dateOfStart: DateTime.now(),
      winner: -1,
      playerOneTitle: 'White',
      playerTwoTitle: 'Black',
      chekcedKing: 2,
    );
    Board board = Board(game: game);

    expect(ComputerLogic.determineAll(board, playerTwo), isNull);
  });
}

// White has a king (4) and a rook (52); black only a king (60) to move.
Board _buildKingsAndRookBoard() {
  Player playerOne = Player(
    id: 0,
    playerTitle: 'White',
    color: ColorType.white,
    turn: true,
    promotable: -1,
    remainingTime: 0,
    king: Solider(
      soliderID: 1,
      soliderType: SoliderType.king,
      soliderposition: 4,
      playerID: 0,
      firstMove: false,
    ),
    queen: [],
    pawns: [],
    horses: [],
    bishops: [],
    rooks: [
      Solider(
        soliderID: 100,
        soliderType: SoliderType.rock,
        soliderposition: 52,
        playerID: 0,
        firstMove: false,
      ),
    ],
  );

  Player playerTwo = Player(
    id: 1,
    playerTitle: 'Black',
    color: ColorType.black,
    turn: false,
    promotable: -1,
    remainingTime: 0,
    king: Solider(
      soliderID: 2,
      soliderType: SoliderType.king,
      soliderposition: 60,
      playerID: 1,
      firstMove: false,
    ),
    queen: [],
    pawns: [],
    horses: [],
    bishops: [],
    rooks: [],
  );

  Game game = Game(
    gameID: 1,
    playerOne: playerOne,
    playerTwo: playerTwo,
    dateOfStart: DateTime.now(),
    winner: -1,
    playerOneTitle: 'White',
    playerTwoTitle: 'Black',
    chekcedKing: 0,
  );
  return Board(game: game);
}