import 'package:chess_app_v1/Backend/kill_Logic.dart';
import 'package:chess_app_v1/Backend/move_logic.dart';
import 'package:chess_app_v1/Models/board.dart';

import 'package:chess_app_v1/Validations/positions_validations.dart';
import 'package:chess_app_v1/Models/solider.dart';
import 'package:chess_app_v1/Models/player.dart';

class CheckLogic {
  static int isAnyKingChecked(Board gameBoard, int currentTouchedIndex) {
    int currentChecked = gameBoard.game.chekcedKing;

    if (PositionsValidations.validSoldierPosiiton(currentTouchedIndex)) {
      int playerID = gameBoard
          .getChessBoardList()[currentTouchedIndex]
          .playerID;
      if (currentChecked == 1 && (playerID == gameBoard.game.playerOne.id)) {
        return currentChecked;
      }
      if ((currentChecked == 2) && (playerID == gameBoard.game.playerTwo.id)) {
        return currentChecked;
      }
    }

    return 0;
  }

  static Solider getSoldierByID(int soldierID, int playerID, Board board) {
    Solider solider = board.getChessBoardList().firstWhere(
      (sold) => sold.soliderID == soldierID && sold.playerID == playerID,
      orElse: Solider.getEmptyInstance,
    );
    return solider;
  }

  static List<int> removeAllUnpreventiveMoves(
    List<int> preventerMoves,
    int preventerID,
    List<int> checkersID,
    int preventerPlayerID,
    int killerPlayerID,
    Board gameBoard,
    bool turn,
  ) {
    if (preventerMoves.isEmpty) {
      return [];
    }
    if (checkersID.isEmpty) {
      return preventerMoves;
    }
    List<int> legalMoves = [];

    for (int i = 0; i < checkersID.length; i++) {
      Solider solider = getSoldierByID(
        checkersID[i],
        killerPlayerID,
        gameBoard,
      );
      if (solider.soliderID > -1) {
        List<int> killerSpots = [];
        Solider preventer = getSoldierByID(
          preventerID,
          preventerPlayerID,
          gameBoard,
        );
        for (int j = 0; j < preventerMoves.length; j++) {
          Board virturalGameBoard = gameBoard.clone();

          virturalGameBoard = MoveLogic.move(
            virturalGameBoard,
            preventerMoves[j],
            preventer.soliderposition,
            turn,
          );
          if (preventer.soliderType == SoliderType.king) {
            virturalGameBoard.editKingPosition(preventerMoves[j], turn);
          }

          bool solverTurn = solider.playerID == gameBoard.game.playerOne.id;

          killerSpots = KillLogic.getAllSoldierKillPostions(
            solider.soliderposition,
            solider.soliderType,
            virturalGameBoard,
            solverTurn,
          );

          if (turn) {
            if (!killerSpots.contains(
              virturalGameBoard.player1KingPosition,
            )) {
              legalMoves.add(preventerMoves[j]);
            }
          } else {
            if (!killerSpots.contains(
              virturalGameBoard.player2kingPosition,
            )) {
              legalMoves.add(preventerMoves[j]);
            }
          }
        }
      }
    }

    return legalMoves;
  }

  static List<int> willMovePreventKilling(
    int currentSoldierPosition,
    int currentSoldierPositionID,
    List<int> checkersID,
    Board gameBoard,
  ) {
    SoliderType soliderType = gameBoard
        .getChessBoardList()[currentSoldierPosition]
        .soliderType;
    bool turn = gameBoard.game.playerOne.turn;
    bool firstMove = gameBoard
        .getChessBoardList()[currentSoldierPosition]
        .firstMove;
    List<int> currentSoldierPositionMoves = MoveLogic.getAllSoldierMoves(
      currentSoldierPosition,
      soliderType,
      gameBoard,
      turn,
      firstMove,
    );
    int currentSoldierPlayerID = gameBoard
        .getChessBoardList()[currentSoldierPosition]
        .playerID;
    int currentSoldierOpeonentPlayerID =
        gameBoard.getChessBoardList()[currentSoldierPosition].playerID ==
            gameBoard.game.playerOne.id
        ? gameBoard.game.playerTwo.id
        : gameBoard.game.playerOne.id;

    List<int> allPrevntingMoves = removeAllUnpreventiveMoves(
      currentSoldierPositionMoves,
      currentSoldierPositionID,
      checkersID,
      currentSoldierPlayerID,
      currentSoldierOpeonentPlayerID,
      gameBoard,
      turn,
    );

    return allPrevntingMoves;
  }

  static List<int> removeAllUnpreventiveKills(
    List<int> preventerKills,
    int preventerID,
    List<int> checkersID,
    int preventerPlayerID,
    int killerPlayerID,
    Board gameBoard,
    bool turn,
  ) {
    if (preventerKills.isEmpty) {
      return [];
    }
    if (checkersID.isEmpty) {
      return preventerKills;
    }
    List<int> legalKills = [];
    // Board virturalGameBoard = gameBoard.clone();

    for (int i = 0; i < checkersID.length; i++) {
      Solider solider = getSoldierByID(
        checkersID[i],
        killerPlayerID,
        gameBoard,
      );
      if (solider.soliderID > -1) {
        List<int> killerSpots = [];
        Solider preventer = getSoldierByID(
          preventerID,
          preventerPlayerID,
          gameBoard,
        );
        for (int j = 0; j < preventerKills.length; j++) {
          Board virturalGameBoard = gameBoard.clone();

          virturalGameBoard = KillLogic.killSoldier(
            preventer.soliderposition,
            virturalGameBoard,

            turn,
            preventerKills[j],
          );
          if (preventer.soliderType == SoliderType.king) {
            virturalGameBoard.editKingPosition(preventerKills[j], turn);
          }

          bool solverTurn = solider.playerID == gameBoard.game.playerOne.id;

          killerSpots = KillLogic.getAllSoldierKillPostions(
            solider.soliderposition,
            solider.soliderType,
            virturalGameBoard,
            solverTurn,
          );

          if (turn) {
            if (!killerSpots.contains(
              virturalGameBoard.player1KingPosition,
            )) {
              legalKills.add(preventerKills[j]);
            }
          } else {
            if (!killerSpots.contains(
              virturalGameBoard.player2kingPosition,
            )) {
              legalKills.add(preventerKills[j]);
            }
          }
        }
      }
    }

    return legalKills;
  }

  static bool canAnySoldierPrventkillByMove(bool turn, Board board) {
    Player currentPlayerToCheckLose = turn
        ? board.game.playerOne
        : board.game.playerTwo;
    Player currentPlayerToCheckWin = turn
        ? board.game.playerTwo
        : board.game.playerOne;
    List<Solider> soldiers = currentPlayerToCheckLose.getPlayerSoldiers();
    List<int> moves = [];
    List<int> unpreventiveMoves = [];
    for (int i = 0; i < soldiers.length; i++) {
      Solider currentSoldier = soldiers[i];
      moves = MoveLogic.getAllSoldierMoves(
        currentSoldier.soliderposition,
        currentSoldier.soliderType,
        board,
        turn,
        currentSoldier.firstMove,
      );
      unpreventiveMoves = CheckLogic.removeAllUnpreventiveMoves(
        moves,
        currentSoldier.soliderID,
        currentPlayerToCheckLose.getAllCheckersSoldier(),
        currentSoldier.playerID,
        currentPlayerToCheckWin.id,
        board,
        turn,
      );
      if (unpreventiveMoves.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  static bool checkMate(bool turn, Board board) {
    bool checkmate = false;
    if (!(canAnySoldierPrventkillByMove(turn, board) &&
        canAnySoldierPrventkillByKill(turn, board))) {
      checkmate = true;
      print("checkmate!!!!");
    }

    return checkmate;
  }

  static bool cantkingMoveOrKill(Solider king, bool turn, Board board) {
    bool cant = false;
    List<int> howManyCan = [];
    List<int> moves = MoveLogic.getAllSoldierMoves(
      king.soliderposition,
      SoliderType.king,
      board,
      turn,
      king.firstMove,
    );
    List<int> kills = KillLogic.getAllSoldierKillPostions(
      king.soliderposition,
      SoliderType.king,
      board,
      turn,
    );
    List<Solider> allKingDefenders = board.game.playerOne.id == king.playerID
        ? board.game.playerOne.getAllSoldiers()
        : board.game.playerTwo.getAllSoldiers();

    for (int i = 0; i < allKingDefenders.length; i++) {
      int position = allKingDefenders[i].soliderposition;
      SoliderType type = allKingDefenders[i].soliderType;
      bool isfirstmove = allKingDefenders[i].firstMove;
      List<int> moves = MoveLogic.getAllSoldierMoves(
        position,
        type,
        board,
        turn,
        isfirstmove,
      );
      for (int j = 0; j < 20; j++) {}
    }
    return cant;
  }

  static bool canAnySoldierPrventkillByKill(bool turn, Board board) {
    Player currentPlayerToCheckLose = turn
        ? board.game.playerOne
        : board.game.playerTwo;
    Player currentPlayerToCheckWin = turn
        ? board.game.playerTwo
        : board.game.playerOne;
    List<Solider> soldiers = currentPlayerToCheckLose.getPlayerSoldiers();
    List<int> kills = [];
    List<int> unpreventiveMoves = [];
    for (int i = 0; i < soldiers.length; i++) {
      Solider currentSoldier = soldiers[i];
      kills = KillLogic.getAllSoldierKillPostions(
        currentSoldier.soliderposition,
        currentSoldier.soliderType,
        board,
        turn,
      );
      unpreventiveMoves = CheckLogic.removeAllUnpreventiveKills(
        kills,
        currentSoldier.soliderID,
        currentPlayerToCheckLose.getAllCheckersSoldier(),
        currentSoldier.playerID,
        currentPlayerToCheckWin.id,
        board,
        turn,
      );
      if (unpreventiveMoves.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  static List<int> willKillPreventKilling(
    int currentSoldierPosition,
    int currentSoldierPositionID,
    List<int> checkersID,
    Board gameBoard,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentSoldierPosition)) {
      return [];
    }
    SoliderType soliderType = gameBoard
        .getChessBoardList()[currentSoldierPosition]
        .soliderType;
    bool turn = gameBoard.game.playerOne.turn;
    int currentSoldierPlayerID = gameBoard
        .getChessBoardList()[currentSoldierPosition]
        .playerID;
    int currentSoldierOponenetPlayerID =
        gameBoard.getChessBoardList()[currentSoldierPosition].playerID ==
            gameBoard.game.playerOne.id
        ? gameBoard.game.playerTwo.id
        : gameBoard.game.playerOne.id;
    List<int> currentSoldierPositionKills = KillLogic.getAllSoldierKillPostions(
      currentSoldierPosition,
      soliderType,
      gameBoard,
      turn,
    );
    List<int> allPrevntingMoves = removeAllUnpreventiveKills(
      currentSoldierPositionKills,
      currentSoldierPositionID,
      checkersID,
      currentSoldierPlayerID,
      currentSoldierOponenetPlayerID,
      gameBoard,
      turn,
    );

    return allPrevntingMoves;
  }

  static List<int> _getAllPossibleAttackersAfterLeavingPosition(
    int currentPosition,
    int placeToMove,
    int playerID,
    bool turn,
    Board gameBoardClone,
  ) {
    List<Solider> attackers = [];
    List<int> allPossibleAttackers = [];

    attackers = gameBoardClone
        .getChessBoardList()
        .where(
          (sold) =>
              (sold.playerID != playerID) &&
              (PositionsValidations.validSoldierPosiiton(sold.soliderposition)),
        )
        .toList();
    if (attackers.isEmpty) {
      return [placeToMove];
    }
    bool currentPositionIsKing = gameBoardClone
            .getChessBoardList()[currentPosition]
            .soliderType ==
        SoliderType.king;

    for (int i = 0; i < attackers.length; i++) {
      Board virtualBoard = gameBoardClone.clone();
      virtualBoard = MoveLogic.move(
        virtualBoard,
        placeToMove,
        currentPosition,
        turn,
      );

      if (currentPositionIsKing) {
        virtualBoard.editKingPosition(placeToMove, turn);
      }

      int whichKingPosition = turn
          ? virtualBoard.player1KingPosition
          : virtualBoard.player2kingPosition;

      bool attackerTurn =
          attackers[i].playerID == gameBoardClone.game.playerOne.id;

      List<int> attackerPlacesToAttackAfterMove =
          KillLogic.getAllSoldierKillPostions(
            attackers[i].soliderposition,
            attackers[i].soliderType,
            virtualBoard,
            attackerTurn,
          );

      if (attackerPlacesToAttackAfterMove.contains(whichKingPosition)) {
        allPossibleAttackers.add(attackers[i].soliderID);
      }
    }

    return allPossibleAttackers;
  }

  static List<int> _getAllPossibleAttackersAfterKillingAPosition(
    int currentPosition,
    int placesToKill,
    int playerID,
    bool turn,
    Board gameBoardClone,
  ) {
    List<Solider> attackers = [];
    List<int> allPossibleAttackers = [];

    attackers = gameBoardClone
        .getChessBoardList()
        .where(
          (sold) =>
              (sold.playerID != playerID) &&
              (PositionsValidations.validSoldierPosiiton(sold.soliderposition)),
        )
        .toList();

    if (attackers.isEmpty) {
      return [placesToKill];
    }
    bool currentPositionIsKing = gameBoardClone
            .getChessBoardList()[currentPosition]
            .soliderType ==
        SoliderType.king;

    for (int i = 0; i < attackers.length; i++) {
      Board virtualBoard = gameBoardClone.clone();
      virtualBoard = KillLogic.killSoldier(
        currentPosition,
        virtualBoard,
        turn,
        placesToKill,
      );

      if (currentPositionIsKing) {
        virtualBoard.editKingPosition(placesToKill, turn);
      }

      int whichKingPosition = turn
          ? virtualBoard.player1KingPosition
          : virtualBoard.player2kingPosition;

      bool attackerTurn =
          attackers[i].playerID == gameBoardClone.game.playerOne.id;

      List<int> attackerPlacesToAttackAfterKill =
          KillLogic.getAllSoldierKillPostions(
            attackers[i].soliderposition,
            attackers[i].soliderType,
            virtualBoard,
            attackerTurn,
          );

      if (attackerPlacesToAttackAfterKill.contains(whichKingPosition)) {
        allPossibleAttackers.add(attackers[i].soliderID);
      }
    }

    return allPossibleAttackers;
  }

  static bool willMoveCauseCheckedKing(
    int currentLocationSoldier,
    int placeToMove,
    int playerID,
    bool turn,
    Board gameBoardClone,
  ) {
    bool canMove = false;

    if (!PositionsValidations.validSoldierPosiiton(currentLocationSoldier) ||
        !PositionsValidations.validSoldierPosiiton(placeToMove)) {
      return canMove;
    }
    if (_getAllPossibleAttackersAfterLeavingPosition(
      currentLocationSoldier,
      placeToMove,
      playerID,
      turn,
      gameBoardClone,
    ).isEmpty) {
      canMove = true;
    }

    return canMove;
  }

  static bool willNotKillCauseCheckedKingOrAboutToBeKilled(
    int currentLocationSoldier,
    int placesToKill,
    int playerID,
    bool turn,
    Board gameBoardClone,
  ) {
    bool canMove = false;

    if (!PositionsValidations.validSoldierPosiiton(currentLocationSoldier) ||
        !PositionsValidations.validSoldierPosiiton(placesToKill)) {
      return canMove;
    }
    if (_getAllPossibleAttackersAfterKillingAPosition(
      currentLocationSoldier,
      placesToKill,
      playerID,
      turn,
      gameBoardClone,
    ).isEmpty) {
      canMove = true;
    }

    return canMove;
  }

  static int isSoldierMayAttacksKings(
    int currentSoldierPosition,
    Board gameboard,

    int whichKing,
  ) {
    if (gameboard.getChessBoardList().isEmpty) {
      return 0;
    }

    if (!PositionsValidations.validSoldierPosiiton(currentSoldierPosition)) {
      return 0;
    }
    SoliderType currentAttackerPositionType = gameboard
        .getChessBoardList()[currentSoldierPosition]
        .soliderType;
    if (PositionsValidations.isPlaceHasNoSoldier(currentAttackerPositionType)) {
      return 0;
    }
    bool turn = gameboard.game.playerOne.turn;
    List<int> positionsToKill = KillLogic.getAllSoldierKillPostions(
      currentSoldierPosition,
      currentAttackerPositionType,
      gameboard,
      turn,
    );
    if (positionsToKill.isEmpty) {
      return 0;
    }

    int attacker = 0;

    if (whichKing == 1) {
      int player1KingPosition = gameboard.game.playerOne.king.soliderposition;
      if (positionsToKill.contains(player1KingPosition)) {
        attacker = 1; //king one under check.
      }
    } else if (whichKing == 2) {
      int player2KingPosition = gameboard.game.playerTwo.king.soliderposition;
      if (positionsToKill.contains(player2KingPosition)) {
        attacker = 2; //king two under check.
      }
    }

    return attacker;
  }
}
