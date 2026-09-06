import 'dart:math';

import 'package:chess_app_v1/Backend/check_logic.dart';
import 'package:chess_app_v1/Backend/kill_Logic.dart';
import 'package:chess_app_v1/Backend/move_logic.dart';
import 'package:chess_app_v1/Models/board.dart';
import 'package:chess_app_v1/Models/computer_turn.dart';
import 'package:chess_app_v1/Models/player.dart';
import 'package:chess_app_v1/Models/solider.dart';
import 'package:chess_app_v1/Validations/positions_validations.dart';

/// Random, rules-respecting computer opponent.
///
/// `determineAll` picks a single legal (move or kill) for the given side and
/// returns it as a [ComputerTurn]. "Legal" here means the same validation the
/// human UI applies: after the move/capture NO enemy piece may attack the
/// moving side's king (handles pins, discovered checks, blocked-in kings and
/// guarded capture squares automatically). The choice itself is uniform
/// random - the AI does no look-ahead or evaluation.
class ComputerLogic {
  /// side: the Player (playerOne or playerTwo) controlled by the computer.
  /// Returns null when the side has no legal move (checkmate/stalemate).
  static ComputerTurn? determineAll(Board gameboard, Player side) {
    bool turn = side.id == gameboard.game.playerOne.id;

    // Each candidate as a (piece, where, isKill) triple.
    List<({Solider piece, int where, bool kill})> candidates = [];

    for (Solider piece in side.getPlayerSoldiers()) {
      int pos = piece.soliderposition;
      if (!PositionsValidations.validSoldierPosiiton(pos)) continue;

      // Legal quiet moves (excluding castling to keep the AI simple).
      List<int> moves = MoveLogic.getAllSoldierMoves(
        pos,
        piece.soliderType,
        gameboard,
        turn,
        piece.firstMove,
      );
      for (int m in moves) {
        if (piece.soliderType == SoliderType.king &&
            (m - pos).abs() == 2 &&
            m ~/ 8 == pos ~/ 8) {
          continue; // skip castling
        }
        if (CheckLogic.willMoveCauseCheckedKing(
          pos,
          m,
          side.id,
          turn,
          gameboard.clone(),
        )) {
          candidates.add((piece: piece, where: m, kill: false));
        }
      }

      // Legal captures.
      List<int> kills = KillLogic.getAllSoldierKillPostions(
        pos,
        piece.soliderType,
        gameboard,
        turn,
      );
      for (int k in kills) {
        if (CheckLogic.willNotKillCauseCheckedKingOrAboutToBeKilled(
          pos,
          k,
          side.id,
          turn,
          gameboard.clone(),
        )) {
          candidates.add((piece: piece, where: k, kill: true));
        }
      }
    }

    if (candidates.isEmpty) return null;

    final chosen = candidates[Random().nextInt(candidates.length)];
    return ComputerTurn(
      currentSoldier: chosen.piece,
      turn: turn,
      type: chosen.kill,
      where: chosen.where,
    );
  }
}
