import 'package:chess_app_v1/Backend/kill_logic.dart';

import 'package:chess_app_v1/Backend/move_logic.dart';
import 'package:chess_app_v1/Models/solider.dart';
import 'package:chess_app_v1/Models/player.dart';
import 'package:chess_app_v1/Models/board.dart';
import 'dart:math';
import 'package:chess_app_v1/Models/computer_turn.dart';
import 'package:chess_app_v1/Validations/positions_validations.dart';

class ComputerLogic {
  static SoliderType _whichType() {
    List<SoliderType> types = [
      SoliderType.bishop,
      SoliderType.king,
      SoliderType.knight,
      SoliderType.pawn,
      SoliderType.queen,
      SoliderType.rock,
    ];
    SoliderType type = types[Random().nextInt(types.length)];
    return type;
  }

  static List<Solider> _getAllSoldierWithType(SoliderType type, Player player) {
    if (type == SoliderType.queen) {
      return player.queen;
    } else if (type == SoliderType.bishop) {
      return player.bishops;
    } else if (type == SoliderType.knight) {
      return player.horses;
    } else if (type == SoliderType.rock) {
      return player.rooks;
    } else if (type == SoliderType.pawn) {
      return player.pawns;
    } else {
      return [];
    }
  }

  static Solider _getRandomSoldierWithType(Player player) {
    SoliderType type = _whichType();
    Solider chosenOne = Solider.getEmptyInstance();
    if (type == SoliderType.king) {
      chosenOne = player.king;
      return chosenOne;
    }
    List<Solider> soldiersWithType = _getAllSoldierWithType(type, player);
    if (soldiersWithType.isEmpty) {
      chosenOne = player.king;
      return chosenOne;
    }
    int index = Random().nextInt(soldiersWithType.length);
    chosenOne = soldiersWithType[index];
    return chosenOne;
  }

  static List<int> _whichPostionToMove(
    Board gameboard,
    Solider currentSoldier,
  ) {
    return MoveLogic.getAllSoldierMoves(
      currentSoldier.soliderposition,
      currentSoldier.soliderType,
      gameboard,
      gameboard.game.playerTwo.turn,
      currentSoldier.firstMove,
    );
  }

  static List<int> _whichPostionTokill(
    Board gameboard,
    Solider currentSoldier,
  ) {
    return KillLogic.getAllSoldierKillPostions(
      currentSoldier.soliderposition,
      currentSoldier.soliderType,
      gameboard,
      gameboard.game.playerTwo.turn,
    );
  }

  // static ComputerTurn determineAll(Board gameboard) {
  //   Solider currentSoldier = _getRandomSoldierWithType(
  //     gameboard.game.playerTwo,
  //   );

  //   int where = -1;
  //   bool killOrMove = _whichProcess() == 1 ? true : false;
  //   List<int> poss = [];
  //   while (!PositionsValidations.validSoldierPosiiton(where)) {
  //     print("where now is: " + where.toString());

  //     if (killOrMove) {
  //       poss = _whichPostionToMove(gameboard, currentSoldier);
  //       if (poss.isNotEmpty && poss[0] != -1) {
  //         where = poss[0];
  //         break;
  //       } else {
  //         killOrMove = false;
  //         poss = _whichPostionTokill(gameboard, currentSoldier);
  //         if (poss.isNotEmpty && poss[0] != -1) {
  //           where = poss[0];
  //           break;
  //         }
  //       }
  //     } else {
  //       poss = _whichPostionTokill(gameboard, currentSoldier);
  //       if (poss.isNotEmpty && poss[0] != -1) {
  //         where = poss[0];
  //         break;
  //       } else {
  //         killOrMove = true;
  //         poss = _whichPostionToMove(gameboard, currentSoldier);
  //         if (poss.isNotEmpty && poss[0] != -1) {
  //           where = poss[0];
  //           break;
  //         }
  //       }
  //     }
  //   }
  //   ComputerTurn computerTurn = ComputerTurn(
  //     currentSoldier: currentSoldier,
  //     turn: gameboard.game.playerOne.turn,
  //     type: killOrMove,
  //     where: where,
  //   );

  //   return computerTurn;
  // }

  static int _whichProcess() {
    return Random().nextInt(2);
  }
}
