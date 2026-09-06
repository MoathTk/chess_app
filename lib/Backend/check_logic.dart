import 'package:chess_app_v1/Backend/kill_Logic.dart';
import 'package:chess_app_v1/Backend/move_logic.dart';
import 'package:chess_app_v1/Models/board.dart';

import 'package:chess_app_v1/Validations/positions_validations.dart';
import 'package:chess_app_v1/Models/solider.dart';
import 'package:chess_app_v1/Models/player.dart';

class CheckLogic {
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
    Solider preventer = getSoldierByID(
      preventerID,
      preventerPlayerID,
      gameBoard,
    );

    for (int j = 0; j < preventerMoves.length; j++) {
      // A move only resolves the check if, after simulating it, NO enemy piece
      // attacks the moving side's king. Checking every enemy piece (rather
      // than only the listed checkers) is what catches pinned defenders,
      // discovered checks and blocked-in kings.
      List<int> attackersAfterMove =
          _getAllPossibleAttackersAfterLeavingPosition(
            preventer.soliderposition,
            preventerMoves[j],
            preventerPlayerID,
            turn,
            gameBoard,
          );

      if (attackersAfterMove.isEmpty) {
        legalMoves.add(preventerMoves[j]);
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
    Solider preventer = getSoldierByID(
      preventerID,
      preventerPlayerID,
      gameBoard,
    );

    for (int j = 0; j < preventerKills.length; j++) {
      // Same principle as the moves filter: after simulating the capture no
      // enemy piece may attack the moving side's king. This rejects capturing
      // a checking piece that is defended by another piece, plus pins and
      // discovered checks that a checker-only scan would miss.
      List<int> attackersAfterKill =
          _getAllPossibleAttackersAfterKillingAPosition(
            preventer.soliderposition,
            preventerKills[j],
            preventerPlayerID,
            turn,
            gameBoard,
          );

      if (attackersAfterKill.isEmpty) {
        legalKills.add(preventerKills[j]);
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
        // The checkers are the opponent's pieces flagged as giving check.
        // Only those dictate which moves actually resolve the check.
        currentPlayerToCheckWin.getAllCheckersSoldier(),
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
    // Checkmate = the side in check can NEITHER escape by moving/blocking
    // NOR by capturing the checking piece. If either is possible, it is not
    // mate, so only declare mate when BOTH prevention paths are impossible.
    bool canPreventByMove = canAnySoldierPrventkillByMove(turn, board);
    bool canPreventByKill = canAnySoldierPrventkillByKill(turn, board);
    bool checkmate = !canPreventByMove && !canPreventByKill;

    return checkmate;
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
        // The checkers are the opponent's pieces flagged as giving check.
        currentPlayerToCheckWin.getAllCheckersSoldier(),
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
    bool currentPositionIsKing =
        gameBoardClone.getChessBoardList()[currentPosition].soliderType ==
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

  // Checks that none of the squares the king travels through during castling
  // (its start square, every intermediate square, and the destination square)
  // is attacked by an opponent piece. Castling is illegal if any of these
  // squares is under attack.
  static bool isCastlePathSafe(
    Board gameBoard,
    int kingFrom,
    int kingTo,
    int playerID,
    bool turn,
  ) {
    // Build the ordered list of squares the king touches on its way:
    // from the starting square up to and including the destination.
    int step = kingTo > kingFrom ? 1 : -1;
    List<int> pathSquares = [];
    for (int sq = kingFrom; sq != kingTo + step; sq += step) {
      pathSquares.add(sq);
    }

    // Determine the opponent pieces that could threaten the king's path.
    List<Solider> attackers = gameBoard
        .getChessBoardList()
        .where(
          (sold) =>
              sold.playerID != playerID &&
              PositionsValidations.validSoldierPosiiton(sold.soliderposition),
        )
        .toList();

    // If the opponent has no pieces on the board the path is trivially safe.
    if (attackers.isEmpty) {
      return true;
    }

    // For every square on the king's path, simulate the king standing there and
    // verify that no opponent piece can attack it.
    for (int i = 0; i < pathSquares.length; i++) {
      int kingSquare = pathSquares[i];
      Board virtualBoard = gameBoard.clone();
      // Move the king onto the current path square and keep the king tracker in
      // sync so the simulator can detect attacks against it.
      virtualBoard = MoveLogic.move(virtualBoard, kingSquare, kingFrom, turn);
      virtualBoard.editKingPosition(kingSquare, turn);

      int whichKingPosition = turn
          ? virtualBoard.player1KingPosition
          : virtualBoard.player2kingPosition;

      for (int j = 0; j < attackers.length; j++) {
        bool attackerTurn =
            attackers[j].playerID == gameBoard.game.playerOne.id;
        List<int> attackerPlacesToAttack = KillLogic.getAllSoldierKillPostions(
          attackers[j].soliderposition,
          attackers[j].soliderType,
          virtualBoard,
          attackerTurn,
        );
        // If any attacker can reach the king's current path square the whole
        // castling move is illegal.
        if (attackerPlacesToAttack.contains(whichKingPosition)) {
          return false;
        }
      }
    }

    return true;
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
    bool currentPositionIsKing =
        gameBoardClone.getChessBoardList()[currentPosition].soliderType ==
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
