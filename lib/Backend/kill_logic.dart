import 'package:chess_app_v1/Backend/move_logic.dart';
import 'package:chess_app_v1/Models/solider.dart';
import 'package:chess_app_v1/Validations/positions_validations.dart';

import 'package:chess_app_v1/Models/board.dart';

class KillLogic {
  static List<int> _getAllPawnKillingPositions(
    int position,
    Board board,
    bool turn,
  ) {
    List<int> killingPosition = [];
    int newPosition = 0;
    if (!PositionsValidations.isSoldierOnTop(position, turn)) {
      if (turn) {
        List<Solider> allSoldiersList = board.getChessBoardList();
        newPosition = position + 7;
        if (PositionsValidations.validSoldierPosiiton(position)) {
          if (PositionsValidations.validSoldierPosiiton(newPosition)) {
            if (allSoldiersList[newPosition].soliderType != SoliderType.none &&
                allSoldiersList[newPosition].playerID !=
                    allSoldiersList[position].playerID) {
              if (!(PositionsValidations.isPawnOnleftSide(position))) {
                killingPosition.add(newPosition);
              }
            }
          }
          newPosition = position + 9;
          if (PositionsValidations.validSoldierPosiiton(newPosition)) {
            if (!(newPosition >= 63)) {
              if (allSoldiersList[newPosition].soliderType !=
                      SoliderType.none &&
                  allSoldiersList[newPosition].playerID !=
                      allSoldiersList[position].playerID) {
                if (!(PositionsValidations.isPawnOnRightSide(position))) {
                  killingPosition.add(newPosition);
                }
              }
            }
          }
        }
      } else {
        List<Solider> allSoldiersList = board.getChessBoardList();
        if (PositionsValidations.validSoldierPosiiton(position)) {
          newPosition = position - 7;
          if (PositionsValidations.validSoldierPosiiton(newPosition)) {
            if (allSoldiersList[newPosition].soliderType != SoliderType.none &&
                allSoldiersList[newPosition].playerID !=
                    allSoldiersList[position].playerID) {
              if (!(PositionsValidations.isPawnOnRightSide(position))) {
                killingPosition.add(newPosition);
              }
            }
          }
          newPosition = position - 9;
          if ((PositionsValidations.validSoldierPosiiton(newPosition))) {
            if (allSoldiersList[newPosition].soliderType != SoliderType.none &&
                allSoldiersList[newPosition].playerID !=
                    allSoldiersList[position].playerID) {
              if (!(PositionsValidations.isPawnOnleftSide(position))) {
                killingPosition.add(newPosition);
              }
            }
          }
        }
      }
    }
    return killingPosition;
  }

  static bool isVeryfarToBeAttacker(
    int currentAttackerPosition,
    SoliderType possibleAttackerType,
    int player1KingPosition,
    int player2KingPosition,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentAttackerPosition) ||
        PositionsValidations.isPlaceHasNoSoldier(possibleAttackerType)) {
      return false;
    }
    bool attacker = false;
    switch (possibleAttackerType) {
      case SoliderType.pawn:
        {
          if ((currentAttackerPosition - player1KingPosition <= 9 &&
                  currentAttackerPosition - player1KingPosition > -1) ||
              (player1KingPosition - currentAttackerPosition <= 9 &&
                  currentAttackerPosition - player1KingPosition > -1)) {
            attacker = true;
          }
        }
      case SoliderType.king:
        attacker = false;
      case SoliderType.queen:
        attacker = false;
      case SoliderType.bishop:
        attacker = false;
      case SoliderType.knight:
        attacker = false;
      case SoliderType.rock:
        attacker = false;
      case SoliderType.none:
        attacker = false;
    }

    return attacker;
  }

  static Board _swapBoardSoldiers(
    int position,
    Board board,
    int positionToKill,
  ) {
    Board newBoard = Board(game: board.game);

    Solider killerSolider = newBoard.getChessBoardList()[position];
    Solider killedSolider = newBoard.getChessBoardList()[positionToKill];
    killedSolider.soliderposition = -1;
    newBoard.getChessBoardList()[positionToKill] = killerSolider;

    newBoard.getChessBoardList()[positionToKill].soliderposition =
        positionToKill;
    newBoard.setKilledSoldier(killedSolider);

    newBoard.getChessBoardList()[position] = Solider.getEmptyInstance();

    return newBoard;
  }

  static int _getSoldierToKillInFrontForRook(
    int currentRookPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentRookPosition) ||
        PositionsValidations.onBottom(currentRookPosition)) {
      return -1;
    }
    int positionToKill = 0;
    SoliderType solidertToKillType = SoliderType.none;
    int currentRookPositionID = -1;
    int positionsToKillID = -1;
    int positionToKillPlayerID = -1;
    int currentRookPositionPlayerID = -1;
    for (int i = 0; i <= 63 - 8; i += 8) {
      positionToKill = currentRookPosition + 8 + i;
      if (PositionsValidations.validSoldierPosiiton(positionToKill)) {
        solidertToKillType = allSoldiersList[positionToKill].soliderType;
        currentRookPositionPlayerID =
            allSoldiersList[currentRookPosition].playerID;
        positionToKillPlayerID = allSoldiersList[positionToKill].playerID;
        positionsToKillID = allSoldiersList[positionToKill].soliderID;
        currentRookPositionID = allSoldiersList[currentRookPosition].soliderID;

        if (solidertToKillType != SoliderType.none &&
            positionToKillPlayerID == currentRookPositionPlayerID) {
          positionToKill = -1;
          break;
        }

        if (solidertToKillType != SoliderType.none &&
            currentRookPositionPlayerID != positionToKillPlayerID &&
            currentRookPositionID != positionsToKillID) {
          positionToKill = allSoldiersList[positionToKill].soliderposition;
          return positionToKill;
        }
      }
      positionToKill = -1;
    }

    return positionToKill;
  }

  static int _getSoldierToKillInBackForRook(
    int currentRookPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentRookPosition) ||
        PositionsValidations.onTop(currentRookPosition)) {
      return -1;
    }
    int positionToKill = 0;
    SoliderType solidertToKillType = SoliderType.none;
    int currentRookPositionID = -1;
    int positionsToKillID = -1;
    int positionToKillPlayerID = -1;
    int currentRookPositionPlayerID = -1;
    for (int i = 0; i <= 63 - 8; i += 8) {
      positionToKill = currentRookPosition - 8 - i;
      if (PositionsValidations.validSoldierPosiiton(positionToKill)) {
        solidertToKillType = allSoldiersList[positionToKill].soliderType;
        currentRookPositionPlayerID =
            allSoldiersList[currentRookPosition].playerID;
        positionToKillPlayerID = allSoldiersList[positionToKill].playerID;
        positionsToKillID = allSoldiersList[positionToKill].soliderID;
        currentRookPositionID = allSoldiersList[currentRookPosition].soliderID;
        if (solidertToKillType != SoliderType.none &&
            positionToKillPlayerID == currentRookPositionPlayerID) {
          positionToKill = -1;
          break;
        }
        if ((solidertToKillType != SoliderType.none) &&
            (currentRookPositionPlayerID != positionToKillPlayerID) &&
            (currentRookPositionID != positionsToKillID)) {
          positionToKill = allSoldiersList[positionToKill].soliderposition;
          return positionToKill;
        }
      }
      positionToKill = -1;
    }

    return positionToKill;
  }

  static int _getSoldierToKillInLeftForRook(
    int currentRookPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentRookPosition) ||
        PositionsValidations.atEndsRows(currentRookPosition)) {
      return -1;
    }
    int end = MoveLogic.getRowEnd(currentRookPosition) - currentRookPosition;
    int positionToKill = 0;
    SoliderType solidertToKillType = SoliderType.none;
    int currentRookPositionID = -1;
    int positionsToKillID = -1;
    int positionToKillPlayerID = -1;
    int currentRookPositionPlayerID = -1;

    for (int i = 0; i < end; i++) {
      positionToKill = currentRookPosition + 1 + i;
      if (PositionsValidations.validSoldierPosiiton(positionToKill)) {
        solidertToKillType = allSoldiersList[positionToKill].soliderType;
        currentRookPositionPlayerID =
            allSoldiersList[currentRookPosition].playerID;
        positionToKillPlayerID = allSoldiersList[positionToKill].playerID;
        positionsToKillID = allSoldiersList[positionToKill].soliderID;
        currentRookPositionID = allSoldiersList[currentRookPosition].soliderID;

        if (solidertToKillType != SoliderType.none &&
            positionToKillPlayerID == currentRookPositionPlayerID) {
          positionToKill = -1;
          break;
        }
        if ((solidertToKillType != SoliderType.none) &&
            (currentRookPositionPlayerID != positionToKillPlayerID) &&
            (currentRookPositionID != positionsToKillID)) {
          positionToKill = allSoldiersList[positionToKill].soliderposition;
          return positionToKill;
        }
      }
      positionToKill = -1;
    }

    return positionToKill;
  }

  static int _getSoldierToKillInRightForRook(
    int currentRookPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentRookPosition) ||
        PositionsValidations.atStartsRows(currentRookPosition)) {
      return -1;
    }
    int positionToKill = 0;
    int start =
        currentRookPosition - MoveLogic.getRowStart(currentRookPosition);
    SoliderType solidertToKillType = SoliderType.none;
    int currentRookPositionID = -1;
    int positionsToKillID = -1;
    int positionToKillPlayerID = -1;
    int currentRookPositionPlayerID = -1;
    for (int i = 0; i < start; i++) {
      positionToKill = currentRookPosition - 1 - i;
      if (PositionsValidations.validSoldierPosiiton(positionToKill)) {
        solidertToKillType = allSoldiersList[positionToKill].soliderType;
        currentRookPositionPlayerID =
            allSoldiersList[currentRookPosition].playerID;
        positionToKillPlayerID = allSoldiersList[positionToKill].playerID;
        positionsToKillID = allSoldiersList[positionToKill].soliderID;
        currentRookPositionID = allSoldiersList[currentRookPosition].soliderID;

        if (solidertToKillType != SoliderType.none &&
            positionToKillPlayerID == currentRookPositionPlayerID) {
          positionToKill = -1;
          break;
        }
        if ((solidertToKillType != SoliderType.none) &&
            (currentRookPositionPlayerID != positionToKillPlayerID) &&
            (currentRookPositionID != positionsToKillID)) {
          return positionToKill;
        }
        if (positionToKill == currentRookPosition) {
          return -1;
        }
      }
      positionToKill = -1;
    }

    return positionToKill;
  }

  static List<int> getAllRookToKillPositions(
    int currentRookPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentRookPosition)) {
      return [];
    }
    if (allSoldiersList.isEmpty) {
      return [];
    }
    List<int> positionsToKill = [];
    positionsToKill.add(
      _getSoldierToKillInFrontForRook(currentRookPosition, allSoldiersList),
    );
    positionsToKill.add(
      _getSoldierToKillInBackForRook(currentRookPosition, allSoldiersList),
    );
    positionsToKill.add(
      _getSoldierToKillInLeftForRook(currentRookPosition, allSoldiersList),
    );
    positionsToKill.add(
      _getSoldierToKillInRightForRook(currentRookPosition, allSoldiersList),
    );

    positionsToKill = positionsToKill.where((kill) => kill != -1).toList();

    return positionsToKill;
  }

  static int _getBishopSoliderPositionToKillInTheDownLeft(
    int currentBishopPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentBishopPosition) ||
        allSoldiersList.isEmpty ||
        PositionsValidations.onBottom(currentBishopPosition) ||
        currentBishopPosition == 7 ||
        PositionsValidations.atEndsRows(currentBishopPosition)) {
      return -1;
    }

    int positionsToKill = -1;
    SoliderType soliderType = SoliderType.none;

    int currentPositionToKill = 0;

    int currentBishopPositionPlayerID = -1;
    int currentBishopPositionToKillPlayerID = -1;
    for (int i = 0; i <= 63 - 8; i += 9) {
      currentPositionToKill = currentBishopPosition + 9 + i;
      if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
        soliderType = allSoldiersList[currentPositionToKill].soliderType;

        currentBishopPositionToKillPlayerID =
            allSoldiersList[currentPositionToKill].playerID;
        currentBishopPositionPlayerID =
            allSoldiersList[currentBishopPosition].playerID;
        if (_isThereAWall(
          currentBishopPositionPlayerID,
          currentBishopPositionToKillPlayerID,
          soliderType,
        )) {
          return -1;
        }
        if (!PositionsValidations.isPlaceHasNoSoldier(soliderType) &&
            currentBishopPositionToKillPlayerID !=
                currentBishopPositionPlayerID) {
          positionsToKill = currentPositionToKill;

          break;
        }
        if (PositionsValidations.accessedEdges(currentPositionToKill)) {
          return -1;
        }
      }
      positionsToKill = -1;
    }

    return positionsToKill;
  }

  static int _getBishopSoliderPositionToKillInTheDownRight(
    int currentBishopPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentBishopPosition) ||
        allSoldiersList.isEmpty ||
        PositionsValidations.onBottom(currentBishopPosition) ||
        currentBishopPosition == 0 ||
        PositionsValidations.atStartsRows(currentBishopPosition)) {
      return -1;
    }

    int positionsToKill = -1;
    SoliderType soliderType = SoliderType.none;

    int currentPositionToKill = 0;

    int currentBishopPositionPlayerID = -1;
    int currentBishopPositionToKillPlayerID = -1;
    for (int i = 0; i <= 63 - 8; i += 7) {
      currentPositionToKill = currentBishopPosition + 7 + i;
      if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
        soliderType = allSoldiersList[currentPositionToKill].soliderType;

        currentBishopPositionToKillPlayerID =
            allSoldiersList[currentPositionToKill].playerID;
        currentBishopPositionPlayerID =
            allSoldiersList[currentBishopPosition].playerID;
        if (_isThereAWall(
          currentBishopPositionPlayerID,
          currentBishopPositionToKillPlayerID,
          soliderType,
        )) {
          return -1;
        }
        if (!PositionsValidations.isPlaceHasNoSoldier(soliderType) &&
            currentBishopPositionToKillPlayerID !=
                currentBishopPositionPlayerID) {
          positionsToKill = currentPositionToKill;

          break;
        }
        if (PositionsValidations.accessedEdges(currentPositionToKill)) {
          return -1;
        }
      }
      positionsToKill = -1;
    }

    return positionsToKill;
  }

  static int _getBishopSoliderPositionToKillInTheTopLeft(
    int currentBishopPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentBishopPosition) ||
        allSoldiersList.isEmpty ||
        PositionsValidations.onTop(currentBishopPosition) ||
        currentBishopPosition == 56 ||
        PositionsValidations.atStartsRows(currentBishopPosition)) {
      return -1;
    }

    int positionsToKill = -1;
    SoliderType soliderType = SoliderType.none;

    int currentPositionToKill = 0;

    int currentBishopPositionPlayerID = -1;
    int currentBishopPositionToKillPlayerID = -1;
    for (int i = 0; i <= 63 - 8; i += 9) {
      currentPositionToKill = currentBishopPosition - 9 - i;
      if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
        soliderType = allSoldiersList[currentPositionToKill].soliderType;

        currentBishopPositionToKillPlayerID =
            allSoldiersList[currentPositionToKill].playerID;
        currentBishopPositionPlayerID =
            allSoldiersList[currentBishopPosition].playerID;
        if (_isThereAWall(
          currentBishopPositionPlayerID,
          currentBishopPositionToKillPlayerID,
          soliderType,
        )) {
          return -1;
        }
        if (!PositionsValidations.isPlaceHasNoSoldier(soliderType) &&
            currentBishopPositionToKillPlayerID !=
                currentBishopPositionPlayerID) {
          positionsToKill = currentPositionToKill;

          break;
        }
        if (PositionsValidations.accessedEdges(currentPositionToKill)) {
          return -1;
        }
      }
      positionsToKill = -1;
    }

    return positionsToKill;
  }

  static bool _isThereAWall(
    int killerPlayerID,
    int killedPlayerID,
    SoliderType killedType,
  ) {
    if (!PositionsValidations.isPlaceHasNoSoldier(killedType) &&
        killedPlayerID == killerPlayerID) {
      return true;
    }
    return false;
  }

  static int _getBishopSoliderPositionToKillInTheTopRight(
    int currentBishopPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentBishopPosition) ||
        allSoldiersList.isEmpty ||
        PositionsValidations.onTop(currentBishopPosition) ||
        PositionsValidations.atEndsRows(currentBishopPosition)) {
      return -1;
    }

    int positionsToKill = -1;
    SoliderType soliderType = SoliderType.none;

    int currentPositionToKill = 0;

    int currentBishopPositionPlayerID = -1;
    int currentBishopPositionToKillPlayerID = -1;
    for (int i = 0; i <= 63 - 8; i += 7) {
      currentPositionToKill = currentBishopPosition - 7 - i;
      if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
        soliderType = allSoldiersList[currentPositionToKill].soliderType;

        currentBishopPositionToKillPlayerID =
            allSoldiersList[currentPositionToKill].playerID;
        currentBishopPositionPlayerID =
            allSoldiersList[currentBishopPosition].playerID;
        if (_isThereAWall(
          currentBishopPositionPlayerID,
          currentBishopPositionToKillPlayerID,
          soliderType,
        )) {
          return -1;
        }
        if (!PositionsValidations.isPlaceHasNoSoldier(soliderType) &&
            currentBishopPositionToKillPlayerID !=
                currentBishopPositionPlayerID) {
          positionsToKill = currentPositionToKill;

          break;
        }
        if (PositionsValidations.accessedEdges(currentPositionToKill)) {
          break;
        }
      }
      positionsToKill = -1;
    }

    return positionsToKill;
  }

  static List<int> _getAllBishopPlacesToKill(
    int currentBishopPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentBishopPosition)) {
      return [];
    }
    List<int> placesToKill = [];

    placesToKill.insert(
      0,
      _getBishopSoliderPositionToKillInTheDownLeft(
        currentBishopPosition,
        allSoldiersList,
      ),
    );

    placesToKill.insert(
      0,
      _getBishopSoliderPositionToKillInTheDownRight(
        currentBishopPosition,
        allSoldiersList,
      ),
    );

    placesToKill.insert(
      0,
      _getBishopSoliderPositionToKillInTheTopLeft(
        currentBishopPosition,
        allSoldiersList,
      ),
    );

    placesToKill.insert(
      0,
      _getBishopSoliderPositionToKillInTheTopRight(
        currentBishopPosition,
        allSoldiersList,
      ),
    );

    placesToKill = placesToKill.where((pose) => pose != -1).toList();
    return placesToKill;
  }

  static List<int> _getAllQueenKillPositions(
    int currentQueenPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentQueenPosition)) {
      return [];
    }
    List<int> placesToKill = [];

    placesToKill.addAll(
      _getAllBishopPlacesToKill(currentQueenPosition, allSoldiersList),
    );
    placesToKill.addAll(
      getAllRookToKillPositions(currentQueenPosition, allSoldiersList),
    );

    placesToKill = placesToKill.where((pose) => pose != -1).toList();
    return placesToKill;
  }

  static List<int> _getAllFrontPlacesKnightMoves(
    int currentKnightPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentKnightPosition)) {
      return [];
    }
    List<int> placesTokill = [];
    int currentPositionToKill = -1;
    int currentKnightPositionPlayerID = 0;
    int currentPositionToKillPlayerID = 0;
    SoliderType currentPositionToMoveType = SoliderType.none;

    if (PositionsValidations.onBottom(currentKnightPosition)) {
      return [];
    }
    if (!PositionsValidations.atEndsRows(currentKnightPosition)) {
      currentPositionToKill = currentKnightPosition + 17; //t

      if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
        currentKnightPositionPlayerID =
            allSoldiersList[currentKnightPosition].playerID;
        currentPositionToKillPlayerID =
            allSoldiersList[currentPositionToKill].playerID;
        currentPositionToMoveType =
            allSoldiersList[currentPositionToKill].soliderType;

        if (!PositionsValidations.isPlaceHasNoSoldier(
              currentPositionToMoveType,
            ) &&
            (currentKnightPositionPlayerID != currentPositionToKillPlayerID)) {
          placesTokill.add(currentPositionToKill);
          currentPositionToKill = -1;
        }
      }
    }

    if (!PositionsValidations.atStartsRows(currentKnightPosition)) {
      currentPositionToKill = currentKnightPosition + 15; //t
      if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
        currentKnightPositionPlayerID =
            allSoldiersList[currentKnightPosition].playerID;
        currentPositionToKillPlayerID =
            allSoldiersList[currentPositionToKill].playerID;
        currentPositionToMoveType =
            allSoldiersList[currentPositionToKill].soliderType;

        if (!PositionsValidations.isPlaceHasNoSoldier(
              currentPositionToMoveType,
            ) &&
            (currentKnightPositionPlayerID != currentPositionToKillPlayerID)) {
          placesTokill.add(currentPositionToKill);
          currentPositionToKill = -1;
        }
      }
    }

    return placesTokill;
  }

  static List<int> _getAllBackPlacesKnightMoves(
    int currentKnightPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentKnightPosition)) {
      return [];
    }
    if (PositionsValidations.onTop(currentKnightPosition)) {
      return [];
    }
    List<int> placesTokill = [];
    int currentPositionToKill = -1;
    int currentKnightPositionPlayerID = 0;
    int currentPositionToKillPlayerID = 0;
    SoliderType currentPositionToMoveType = SoliderType.none;

    if (!PositionsValidations.atEndsRows(currentKnightPosition)) {
      currentPositionToKill = currentKnightPosition - 17; //t
      if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
        currentKnightPositionPlayerID =
            allSoldiersList[currentKnightPosition].playerID;
        currentPositionToKillPlayerID =
            allSoldiersList[currentPositionToKill].playerID;
        currentPositionToMoveType =
            allSoldiersList[currentPositionToKill].soliderType;

        if (!PositionsValidations.isPlaceHasNoSoldier(
              currentPositionToMoveType,
            ) &&
            (currentKnightPositionPlayerID != currentPositionToKillPlayerID)) {
          placesTokill.add(currentPositionToKill);
          currentPositionToKill = 0;
        }
      }
    }

    if (!PositionsValidations.atStartsRows(currentKnightPosition)) {
      currentPositionToKill = currentKnightPosition - 15; //t
      if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
        currentKnightPositionPlayerID =
            allSoldiersList[currentKnightPosition].playerID;
        currentPositionToKillPlayerID =
            allSoldiersList[currentPositionToKill].playerID;
        currentPositionToMoveType =
            allSoldiersList[currentPositionToKill].soliderType;

        if (!PositionsValidations.isPlaceHasNoSoldier(
              currentPositionToMoveType,
            ) &&
            (currentKnightPositionPlayerID != currentPositionToKillPlayerID)) {
          placesTokill.add(currentPositionToKill);
          currentPositionToKill = 0;
        }
      }
    }

    return placesTokill;
  }

  static List<int> _getAllLeftPlacesKnightMoves(
    int currentKnightPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentKnightPosition)) {
      return [];
    }
    List<int> placesTokill = [];
    int currentPositionToKill = -1;
    int currentKnightPositionPlayerID = 0;
    int currentPositionToKillPlayerID = 0;
    SoliderType currentPositionToMoveType = SoliderType.none;

    if (!PositionsValidations.atStartsRows(currentKnightPosition)) {
      if (!PositionsValidations.onBottom(currentKnightPosition)) {
        if (PositionsValidations.notOnSecondColumn(currentKnightPosition)) {
          currentPositionToKill = currentKnightPosition + 6; //t
          if (PositionsValidations.validSoldierPosiiton(
            currentPositionToKill,
          )) {
            currentKnightPositionPlayerID =
                allSoldiersList[currentKnightPosition].playerID;
            currentPositionToKillPlayerID =
                allSoldiersList[currentPositionToKill].playerID;
            currentPositionToMoveType =
                allSoldiersList[currentPositionToKill].soliderType;

            if (!PositionsValidations.isPlaceHasNoSoldier(
                  currentPositionToMoveType,
                ) &&
                (currentKnightPositionPlayerID !=
                    currentPositionToKillPlayerID)) {
              placesTokill.add(currentPositionToKill);
              currentPositionToKill = 0;
            }
          }
        }
      }
    }

    if (!PositionsValidations.atEndsRows(currentKnightPosition)) {
      if (!PositionsValidations.onTop(currentKnightPosition)) {
        if (PositionsValidations.notOnSecondColumn(currentKnightPosition)) {
          currentPositionToKill = currentKnightPosition - 8 - 2; //t
          if (PositionsValidations.validSoldierPosiiton(
            currentPositionToKill,
          )) {
            currentKnightPositionPlayerID =
                allSoldiersList[currentKnightPosition].playerID;
            currentPositionToKillPlayerID =
                allSoldiersList[currentPositionToKill].playerID;
            currentPositionToMoveType =
                allSoldiersList[currentPositionToKill].soliderType;

            if (!PositionsValidations.isPlaceHasNoSoldier(
                  currentPositionToMoveType,
                ) &&
                (currentKnightPositionPlayerID !=
                    currentPositionToKillPlayerID)) {
              placesTokill.add(currentPositionToKill);
              currentPositionToKill = 0;
            }
          }
        }
      }
    }

    return placesTokill;
  }

  static List<int> _getAllRightPlacesKnightMoves(
    int currentKnightPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentKnightPosition)) {
      return [];
    }
    List<int> placesTokill = [];
    int currentPositionToKill = -1;
    int currentKnightPositionPlayerID = 0;
    int currentPositionToKillPlayerID = 0;
    SoliderType currentPositionToMoveType = SoliderType.none;

    if (!PositionsValidations.atEndsRows(currentKnightPosition)) {
      if (!PositionsValidations.onBottom(currentKnightPosition)) {
        if (PositionsValidations.notOnSeventhColumn(currentKnightPosition)) {
          currentPositionToKill = currentKnightPosition + 10; //t
          if (PositionsValidations.validSoldierPosiiton(
            currentPositionToKill,
          )) {
            currentKnightPositionPlayerID =
                allSoldiersList[currentKnightPosition].playerID;
            currentPositionToKillPlayerID =
                allSoldiersList[currentPositionToKill].playerID;
            currentPositionToMoveType =
                allSoldiersList[currentPositionToKill].soliderType;

            if (!PositionsValidations.isPlaceHasNoSoldier(
                  currentPositionToMoveType,
                ) &&
                (currentKnightPositionPlayerID !=
                    currentPositionToKillPlayerID)) {
              placesTokill.add(currentPositionToKill);
              currentPositionToKill = 0;
            }
          }
        }
      }
    }

    if (!PositionsValidations.atStartsRows(currentKnightPosition)) {
      if (!PositionsValidations.onTop(currentKnightPosition)) {
        if (PositionsValidations.notOnSeventhColumn(currentKnightPosition)) {
          currentPositionToKill = currentKnightPosition - 6; //t
          if (PositionsValidations.validSoldierPosiiton(
            currentPositionToKill,
          )) {
            currentKnightPositionPlayerID =
                allSoldiersList[currentKnightPosition].playerID;
            currentPositionToKillPlayerID =
                allSoldiersList[currentPositionToKill].playerID;
            currentPositionToMoveType =
                allSoldiersList[currentPositionToKill].soliderType;

            if (!PositionsValidations.isPlaceHasNoSoldier(
                  currentPositionToMoveType,
                ) &&
                (currentKnightPositionPlayerID !=
                    currentPositionToKillPlayerID)) {
              placesTokill.add(currentPositionToKill);
              currentPositionToKill = 0;
            }
          }
        }
      }
    }

    return placesTokill;
  }

  static int _getKingFrontKill(
    int currentkingPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentkingPosition) ||
        PositionsValidations.onBottom(currentkingPosition)) {
      return -1;
    }
    int placesToKill = currentkingPosition + 8;

    if (PositionsValidations.validSoldierPosiiton(placesToKill)) {
      SoliderType placeToKillSoldierType =
          allSoldiersList[placesToKill].soliderType;
      int placeToKillPlayerID = allSoldiersList[placesToKill].playerID;
      int currentkingPositionPlayerID =
          allSoldiersList[currentkingPosition].playerID;
      if (!PositionsValidations.isPlaceHasNoSoldier(placeToKillSoldierType) &&
          !PositionsValidations.areIdsEquavilant(
            placeToKillPlayerID,
            currentkingPositionPlayerID,
          )) {
        return placesToKill;
      }
    }

    return -1;
  }

  static int _getKingBackKill(
    int currentkingPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentkingPosition) ||
        PositionsValidations.onBottom(currentkingPosition)) {
      return -1;
    }
    int placesToKill = currentkingPosition - 8;

    if (PositionsValidations.validSoldierPosiiton(placesToKill)) {
      SoliderType placeToKillSoldierType =
          allSoldiersList[placesToKill].soliderType;
      int placeToKillPlayerID = allSoldiersList[placesToKill].playerID;
      int currentkingPositionPlayerID =
          allSoldiersList[currentkingPosition].playerID;
      if (!PositionsValidations.isPlaceHasNoSoldier(placeToKillSoldierType) &&
          !PositionsValidations.areIdsEquavilant(
            placeToKillPlayerID,
            currentkingPositionPlayerID,
          )) {
        return placesToKill;
      }
    }

    return -1;
  }

  static List<int> _getAllKingLeftKills(
    int currentkingPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentkingPosition) ||
        PositionsValidations.atStartsRows(currentkingPosition)) {
      return [];
    }

    List<int> placesToKill = [];
    int currentPositionToKill = -1;
    SoliderType currentPositionToMoveSoldierType = SoliderType.none;
    currentPositionToKill = currentkingPosition - 9;
    if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
      currentPositionToMoveSoldierType =
          allSoldiersList[currentPositionToKill].soliderType;
      int placeToKillPlayerID = allSoldiersList[currentPositionToKill].playerID;
      int currentkingPositionPlayerID =
          allSoldiersList[currentkingPosition].playerID;
      if (!PositionsValidations.isPlaceHasNoSoldier(
            currentPositionToMoveSoldierType,
          ) &&
          !PositionsValidations.areIdsEquavilant(
            placeToKillPlayerID,
            currentkingPositionPlayerID,
          )) {
        placesToKill.add(currentPositionToKill);
      }
    }

    currentPositionToKill = currentkingPosition - 1;
    if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
      currentPositionToMoveSoldierType =
          allSoldiersList[currentPositionToKill].soliderType;
      int placeToKillPlayerID = allSoldiersList[currentPositionToKill].playerID;
      int currentkingPositionPlayerID =
          allSoldiersList[currentkingPosition].playerID;
      if (!PositionsValidations.isPlaceHasNoSoldier(
            currentPositionToMoveSoldierType,
          ) &&
          !PositionsValidations.areIdsEquavilant(
            placeToKillPlayerID,
            currentkingPositionPlayerID,
          )) {
        placesToKill.add(currentPositionToKill);
      }
    }

    currentPositionToKill = currentkingPosition + 7;
    if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
      currentPositionToMoveSoldierType =
          allSoldiersList[currentPositionToKill].soliderType;
      int placeToKillPlayerID = allSoldiersList[currentPositionToKill].playerID;
      int currentkingPositionPlayerID =
          allSoldiersList[currentkingPosition].playerID;
      if (!PositionsValidations.isPlaceHasNoSoldier(
            currentPositionToMoveSoldierType,
          ) &&
          !PositionsValidations.areIdsEquavilant(
            placeToKillPlayerID,
            currentkingPositionPlayerID,
          )) {
        placesToKill.add(currentPositionToKill);
      }
    }
    return placesToKill;
  }

  static List<int> _getAllKingRightKills(
    int currentkingPosition,
    List<Solider> allSoldiersList,
  ) {
    List<int> placesToKill = [];
    int currentPositionToKill = -1;
    SoliderType currentPositionToMoveSoldierType = SoliderType.none;
    currentPositionToKill = currentkingPosition - 7;
    if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
      currentPositionToMoveSoldierType =
          allSoldiersList[currentPositionToKill].soliderType;
      int placeToKillPlayerID = allSoldiersList[currentPositionToKill].playerID;
      int currentkingPositionPlayerID =
          allSoldiersList[currentkingPosition].playerID;
      if (!PositionsValidations.isPlaceHasNoSoldier(
            currentPositionToMoveSoldierType,
          ) &&
          !PositionsValidations.areIdsEquavilant(
            placeToKillPlayerID,
            currentkingPositionPlayerID,
          )) {
        placesToKill.add(currentPositionToKill);
      }
    }

    currentPositionToKill = currentkingPosition + 1;
    if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
      currentPositionToMoveSoldierType =
          allSoldiersList[currentPositionToKill].soliderType;
      int placeToKillPlayerID = allSoldiersList[currentPositionToKill].playerID;
      int currentkingPositionPlayerID =
          allSoldiersList[currentkingPosition].playerID;
      if (!PositionsValidations.isPlaceHasNoSoldier(
            currentPositionToMoveSoldierType,
          ) &&
          !PositionsValidations.areIdsEquavilant(
            placeToKillPlayerID,
            currentkingPositionPlayerID,
          )) {
        placesToKill.add(currentPositionToKill);
      }
    }

    currentPositionToKill = currentkingPosition + 9;
    if (PositionsValidations.validSoldierPosiiton(currentPositionToKill)) {
      currentPositionToMoveSoldierType =
          allSoldiersList[currentPositionToKill].soliderType;
      int placeToKillPlayerID = allSoldiersList[currentPositionToKill].playerID;
      int currentkingPositionPlayerID =
          allSoldiersList[currentkingPosition].playerID;
      if (!PositionsValidations.isPlaceHasNoSoldier(
            currentPositionToMoveSoldierType,
          ) &&
          !PositionsValidations.areIdsEquavilant(
            placeToKillPlayerID,
            currentkingPositionPlayerID,
          )) {
        placesToKill.add(currentPositionToKill);
      }
    }
    return placesToKill;
  }

  static List<int> _getAllKnightToKillPositions(
    int currentKnightPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentKnightPosition)) {
      return [];
    }

    List<int> positionsToKill = [];
    positionsToKill.addAll(
      _getAllFrontPlacesKnightMoves(currentKnightPosition, allSoldiersList),
    );
    positionsToKill.addAll(
      _getAllBackPlacesKnightMoves(currentKnightPosition, allSoldiersList),
    );
    positionsToKill.addAll(
      _getAllLeftPlacesKnightMoves(currentKnightPosition, allSoldiersList),
    );
    positionsToKill.addAll(
      _getAllRightPlacesKnightMoves(currentKnightPosition, allSoldiersList),
    );

    return positionsToKill;
  }

  static List<int> _getAllKingMoves(
    int currentkingPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentkingPosition)) {
      return [];
    }
    List<int> placesToKill = [];
    placesToKill.add(_getKingFrontKill(currentkingPosition, allSoldiersList));

    placesToKill.add(_getKingBackKill(currentkingPosition, allSoldiersList));

    placesToKill.addAll(
      _getAllKingLeftKills(currentkingPosition, allSoldiersList),
    );

    placesToKill.addAll(
      _getAllKingRightKills(currentkingPosition, allSoldiersList),
    );

    placesToKill = placesToKill.where((pose) => pose != -1).toList();

    return placesToKill;
  }

  static Board killSoldier(
    int position,
    Board board,
    bool turn,
    int positionToKill,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(position) ||
        !PositionsValidations.validSoldierPosiiton(positionToKill)) {
      return board;
    }
    board = _swapBoardSoldiers(position, board, positionToKill);
    return board;
  }

  static List<int> getAllSoldierKillPostions(
    int position,
    SoliderType type,
    Board board,
    bool turn,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(position)) {
      return [];
    }
    List<int> moves = [];
    switch (type) {
      case SoliderType.pawn:
        moves = _getAllPawnKillingPositions(position, board, turn);
      case SoliderType.rock:
        moves = getAllRookToKillPositions(position, board.getChessBoardList());
      case SoliderType.bishop:
        moves = _getAllBishopPlacesToKill(position, board.getChessBoardList());
      case SoliderType.queen:
        moves = _getAllQueenKillPositions(position, board.getChessBoardList());
      case SoliderType.knight:
        moves = _getAllKnightToKillPositions(
          position,
          board.getChessBoardList(),
        );

      case SoliderType.king:
        moves = _getAllKingMoves(position, board.getChessBoardList());

      case SoliderType.none:
        moves = [];
    }

    return moves;
  }
}
