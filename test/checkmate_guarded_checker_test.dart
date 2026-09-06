import 'package:flutter_test/flutter_test.dart';

import 'package:chess_app_v1/Backend/check_logic.dart';
import 'package:chess_app_v1/Models/Game.dart';
import 'package:chess_app_v1/Models/board.dart';
import 'package:chess_app_v1/Models/player.dart';
import 'package:chess_app_v1/Models/solider.dart';

// Regression test: checkmate must be detected even when the only legal-looking
// escape is capturing the checking piece, IF that checking piece is guarded by
// another enemy piece. Previously the mate search only re-checked the attack
// spots of the listed checkers after a simulated king capture, so it treated a
// guarded checker as capturable and wrongly declared the king NOT mated.
void main() {
  test('king is mated when the checking piece is guarded', () {
    Board board = _buildGuardedCheckerMateBoard();

    // Sanity: the rook really is giving check to the black king.
    int check = CheckLogic.isSoldierMayAttacksKings(52, board, 2);
    expect(check, 2);

    // Black (losing side, turn = false) is mated despite being able to
    // "capture" the checking rook, because that rook is defended.
    expect(CheckLogic.checkMate(false, board), true);
  });
}

Board _buildGuardedCheckerMateBoard() {
    // Board layout (index = row * 8 + col):
    //   White rook "C" on 51 (row 6, col 3) - covers rank-7 square 59.
    //   White rook "A" on 52 (row 6, col 4) - THE checker, one step from the
    //     black king, so capturing it looks like the only escape.
    //   White rook "B" on 53 (row 6, col 5) - guards rook A's square (and the
    //     rank-7 square 61). The king cannot capture it either because rook A
    //     covers square 53.
    //   Black king on 60 (row 7, col 4), with no other black pieces left.
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

    return Board(game: game);
}