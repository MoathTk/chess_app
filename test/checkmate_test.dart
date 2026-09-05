import 'package:flutter_test/flutter_test.dart';

import 'package:chess_app_v1/Backend/check_logic.dart';
import 'package:chess_app_v1/Models/board.dart';
import 'package:chess_app_v1/Models/Game.dart';
import 'package:chess_app_v1/Models/player.dart';
import 'package:chess_app_v1/Models/solider.dart';

// Builds a back-rank mate:
//   White (playerOne) rook at 56, black (playerTwo) king at 59,
//   blocked by black pawns at 50, 51, 52. The rook controls 57..63 along
//   rank 7, so the king has no safe exit and nothing can block/capture.
Board _buildBackRankMateBoard() {
  Solider emptyKing = Solider(
    soliderID: 101,
    soliderType: SoliderType.king,
    soliderposition: 4,
    playerID: 1,
    firstMove: false,
  );
  Solider matedKing = Solider(
    soliderID: 201,
    soliderType: SoliderType.king,
    soliderposition: 59,
    playerID: 2,
    firstMove: false,
  );

  Solider emptyQueen = Solider(
    soliderID: 102,
    soliderType: SoliderType.queen,
    soliderposition: -1,
    playerID: 1,
    firstMove: false,
  );
  Solider matedQueen = Solider(
    soliderID: 202,
    soliderType: SoliderType.queen,
    soliderposition: -1,
    playerID: 2,
    firstMove: false,
  );

  Solider rook = Solider(
    soliderID: 103,
    soliderType: SoliderType.rock,
    soliderposition: 56,
    playerID: 1,
    firstMove: false,
    // The engine flags the piece delivering the check as a checker before
    // evaluating mate, so the mating rook must be flagged here too.
    checker: true,
  );

  Solider emptyPawn(int id) => Solider(
        soliderID: id,
        soliderType: SoliderType.pawn,
        soliderposition: -1,
        playerID: 1,
        firstMove: false,
      );

  List<Solider> blockPawns = [50, 51, 52]
      .map(
        (pos) => Solider(
          soliderID: 210 + pos,
          soliderType: SoliderType.pawn,
          soliderposition: pos,
          playerID: 2,
          firstMove: false,
        ),
      )
      .toList();

  Player white = Player(
    id: 1,
    playerTitle: 'White',
    king: emptyKing,
    queen: [emptyQueen],
    color: ColorType.white,
    turn: true,
    pawns: List.generate(8, emptyPawn),
    rooks: [rook],
    horses: [],
    bishops: [],
    promotable: -1,
    remainingTime: 0,
  );

  Player black = Player(
    id: 2,
    playerTitle: 'Black',
    king: matedKing,
    queen: [matedQueen],
    color: ColorType.black,
    turn: false,
    pawns: blockPawns,
    rooks: [],
    horses: [],
    bishops: [],
    promotable: -1,
    remainingTime: 0,
  );

  Game game = Game(
    gameID: 1,
    playerOne: white,
    playerTwo: black,
    dateOfStart: DateTime.now(),
    winner: -1,
    playerOneTitle: 'White',
    playerTwoTitle: 'Black',
    chekcedKing: 0,
    mode: 0,
  );

  return Board(game: game);
}

void main() {
  test('checkMate detects a real back-rank mate', () {
    Board board = _buildBackRankMateBoard();
    // Black (playerTwo) is the one in check/mate: turn == false.
    expect(CheckLogic.checkMate(false, board), isTrue);
  });

  test('checkMate is NOT mate when the checker can be captured', () {
    // King at 59, white rook at 60 (adjacent, underfended): the king can
    // capture the rook, so this is NOT checkmate.
    Board board = _buildBackRankMateBoard();
    // Move the white rook next to the black king by rebuilding.
    Solider rook = board.getChessBoardList()[56];
    rook.soliderposition = 60;
    board.getChessBoardList()[56] = Solider.getEmptyInstance();
    board.getChessBoardList()[60] = rook;

    expect(CheckLogic.checkMate(false, board), isFalse);
  });
}