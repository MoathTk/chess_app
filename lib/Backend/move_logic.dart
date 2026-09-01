import 'package:chess_app_v1/Models/board.dart';
import 'package:chess_app_v1/Validations/positions_validations.dart';
import 'package:chess_app_v1/Models/solider.dart';

class MoveLogic {
  static List<int> _placesToMovePawn(
    bool firstMove,
    Board board,
    bool turn,
    int position,
  ) {
    List<int> location = [];
    // location.add(position);
    int currentPwanLocation = position;
    if (PositionsValidations.validSoldierPosiiton(currentPwanLocation)) {
      bool hurdle = false;
      if (!PositionsValidations.isSoldierOnTop(currentPwanLocation, turn)) {
        if (turn) {
          if (firstMove) {
            if (board
                    .getChessBoardList()[currentPwanLocation + 8]
                    .soliderType ==
                SoliderType.none) {
              location.add(currentPwanLocation + 8);
            } else if (board
                    .getChessBoardList()[currentPwanLocation + 8]
                    .soliderType !=
                SoliderType.none) {
              hurdle = true;
            }
            if (board
                        .getChessBoardList()[currentPwanLocation + 16]
                        .soliderType ==
                    SoliderType.none &&
                !hurdle) {
              location.add(currentPwanLocation + 16);
            }
          } else {
            if (board
                    .getChessBoardList()[currentPwanLocation + 8]
                    .soliderType ==
                SoliderType.none) {
              location.add(currentPwanLocation + 8);
            }
          }
        } else {
          if (firstMove) {
            if (board
                    .getChessBoardList()[currentPwanLocation - 8]
                    .soliderType ==
                SoliderType.none) {
              location.add(currentPwanLocation - 8);
            } else if (board
                    .getChessBoardList()[currentPwanLocation - 8]
                    .soliderType !=
                SoliderType.none) {
              hurdle = true;
            }
            if (board
                        .getChessBoardList()[currentPwanLocation - 16]
                        .soliderType ==
                    SoliderType.none &&
                !hurdle) {
              location.add(currentPwanLocation - 16);
            }
          } else {
            if (board
                    .getChessBoardList()[currentPwanLocation - 8]
                    .soliderType ==
                SoliderType.none) {
              location.add(currentPwanLocation - 8);
            }
          }
        }
      }
    }
    return location;
  }

  static int getRowEnd(int currentPosition) {
    List<int> endRows = [7, 15, 23, 31, 39, 47, 55, 63];
    if (currentPosition != 63) {
      return endRows.firstWhere(
        (rowNum) => currentPosition < rowNum,
        orElse: () => 63,
      );
    }

    return 63;
  }

  static int getRowStart(int currentPosition) {
    List<int> startRows = [0, 8, 16, 24, 32, 40, 48, 56];

    if (currentPosition != 0) {
      return startRows.lastWhere(
        (rowNum) => currentPosition > rowNum,
        orElse: () => 0,
      );
    }
    return 0;
  }

  static List<int> _frontPlacesToMoveRook(
    int currentRookPosition,
    List<Solider> allSoldiersList,
  ) {
    List<int> placesToMove = [];
    int positionToAdd = -1;
    SoliderType currentSoldierType = SoliderType.none;
    for (int i = 0; i <= 63 - 8; i += 8) {
      positionToAdd = currentRookPosition + 8 + i;

      if (PositionsValidations.validSoldierPosiiton(positionToAdd)) {
        currentSoldierType = allSoldiersList[positionToAdd].soliderType;
        if (PositionsValidations.isPlaceHasNoSoldier(currentSoldierType)) {
          placesToMove.add(positionToAdd);
        } else {
          break;
        }
      }
    }

    return placesToMove;
  }

  static List<int> _backPlacesToMoveRook(
    int currentRookPosition,
    List<Solider> allSoldiersList,
  ) {
    List<int> placesToMove = [];
    int positionToAdd = -1;
    SoliderType currentSoldierType = SoliderType.none;
    for (int i = 0; i <= 63 - 8; i += 8) {
      positionToAdd = currentRookPosition - 8 - i;

      if (PositionsValidations.validSoldierPosiiton(positionToAdd)) {
        currentSoldierType = allSoldiersList[positionToAdd].soliderType;
        if (PositionsValidations.isPlaceHasNoSoldier(currentSoldierType)) {
          placesToMove.add(positionToAdd);
        } else {
          break;
        }
      }
    }

    return placesToMove;
  }

  static List<int> _leftPlacesToMoveRook(
    int currentRookPosition,
    List<Solider> allSoldiersList,
  ) {
    if (PositionsValidations.atStartsRows(currentRookPosition)) {
      return [];
    }
    List<int> placesToMove = [];
    int positionToAdd = -1;
    SoliderType currentSoldierType = SoliderType.none;
    int start = currentRookPosition - getRowStart(currentRookPosition);
    for (int i = 0; i < start; i++) {
      positionToAdd = currentRookPosition - 1 - i;
      if (PositionsValidations.validSoldierPosiiton(positionToAdd)) {
        currentSoldierType = allSoldiersList[positionToAdd].soliderType;
        if (PositionsValidations.isPlaceHasNoSoldier(currentSoldierType)) {
          placesToMove.add(positionToAdd);
        } else {
          break;
        }
      }
    }

    return placesToMove;
  }

  static List<int> _rightPlacesToMoveRook(
    int currentRookPosition,
    List<Solider> allSoldiersList,
  ) {
    if (PositionsValidations.atEndsRows(currentRookPosition)) {
      return [];
    }
    List<int> placesToMove = [];
    int positionToAdd = -1;
    SoliderType currentSoldierType = SoliderType.none;
    int end = getRowEnd(currentRookPosition) - currentRookPosition;
    for (int i = 0; i < end; i++) {
      positionToAdd = currentRookPosition + 1 + i;

      if (PositionsValidations.validSoldierPosiiton(positionToAdd)) {
        currentSoldierType = allSoldiersList[positionToAdd].soliderType;
        if (PositionsValidations.isPlaceHasNoSoldier(currentSoldierType)) {
          placesToMove.add(positionToAdd);
        } else {
          break;
        }
      }
    }

    return placesToMove;
  }

  static List<int> _placesToMoveRook(int currentRookPosition, Board board) {
    List<int> placesToMove = [];

    List<Solider> soliders = board.getChessBoardList();
    //see rook front places.

    placesToMove.insertAll(
      0,
      _frontPlacesToMoveRook(currentRookPosition, soliders),
    );

    placesToMove.insertAll(
      0,
      _backPlacesToMoveRook(currentRookPosition, soliders),
    );
    //see rook right places.
    placesToMove.insertAll(
      0,
      _rightPlacesToMoveRook(currentRookPosition, soliders),
    );

    //see rook left places.

    placesToMove.insertAll(
      0,
      _leftPlacesToMoveRook(currentRookPosition, soliders),
    );

    return placesToMove;
  }

  static List<int> _getAllBishopPlaceToMoveDownRight(
    int currentBishopPosition,
    List<Solider> allSoldiersList,
  ) {
    if (PositionsValidations.onBottom(currentBishopPosition) ||
        PositionsValidations.atEndsRows(currentBishopPosition)) {
      return [];
    }
    List<int> placesToMove = [];
    SoliderType soliderType = SoliderType.none;
    int currentPositionToMove = 0;
    for (int i = 0; i <= 63 - 8; i += 9) {
      currentPositionToMove = currentBishopPosition + 9 + i;
      if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
        soliderType = allSoldiersList[currentPositionToMove].soliderType;
        if (PositionsValidations.isPlaceHasNoSoldier(soliderType)) {
          if ((!PositionsValidations.atEndsRows(currentPositionToMove))) {
            placesToMove.add(currentPositionToMove);
          } else {
            placesToMove.add(currentPositionToMove);
            break;
          }
        } else {
          break;
        }
      }
    }

    return placesToMove;
  }

  static List<int> _getAllBishopPlaceToMoveBackLeft(
    int currentBishopPosition,
    List<Solider> allSoldiersList,
  ) {
    if (PositionsValidations.onTop(currentBishopPosition) ||
        PositionsValidations.atStartsRows(currentBishopPosition)) {
      return [];
    }
    List<int> placesToMove = [];
    SoliderType soliderType = SoliderType.none;
    int currentPositionToMove = 0;
    for (int i = 0; i <= 63 - 8; i += 9) {
      currentPositionToMove = currentBishopPosition - 9 - i;
      if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
        soliderType = allSoldiersList[currentPositionToMove].soliderType;
        if (PositionsValidations.isPlaceHasNoSoldier(soliderType)) {
          if ((!PositionsValidations.atEndsRows(currentPositionToMove))) {
            placesToMove.add(currentPositionToMove);
          } else {
            //placesToMove.add(currentPositionToMove);
            break;
          }
        } else {
          break;
        }
      }
    }

    return placesToMove;
  }

  static List<int> _getAllBishopPlaceToMoveBackRight(
    int currentBishopPosition,
    List<Solider> allSoldiersList,
  ) {
    if (PositionsValidations.onTop(currentBishopPosition) ||
        PositionsValidations.atEndsRows(currentBishopPosition)) {
      return [];
    }
    List<int> placesToMove = [];
    SoliderType soliderType = SoliderType.none;
    int currentPositionToMove = 0;
    for (int i = 0; i <= 63 - 8; i += 7) {
      currentPositionToMove = currentBishopPosition - 7 - i;
      if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
        soliderType = allSoldiersList[currentPositionToMove].soliderType;
        if (PositionsValidations.isPlaceHasNoSoldier(soliderType)) {
          if ((!PositionsValidations.atEndsRows(currentPositionToMove))) {
            placesToMove.add(currentPositionToMove);
          } else {
            placesToMove.add(currentPositionToMove);
            break;
          }
        } else {
          break;
        }
      }
    }

    return placesToMove;
  }

  static List<int> _getAllBishopPlaceToMoveDownLeft(
    int currentBishopPosition,
    List<Solider> allSoldiersList,
  ) {
    if (PositionsValidations.onBottom(currentBishopPosition) ||
        PositionsValidations.atStartsRows(currentBishopPosition)) {
      return [];
    }
    List<int> placesToMove = [];
    SoliderType soliderType = SoliderType.none;
    int currentPositionToMove = 0;
    for (int i = 0; i <= 63 - 8; i += 7) {
      currentPositionToMove = currentBishopPosition + 7 + i;
      if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
        soliderType = allSoldiersList[currentPositionToMove].soliderType;
        if (PositionsValidations.isPlaceHasNoSoldier(soliderType)) {
          if ((!PositionsValidations.atStartsRows(currentPositionToMove))) {
            placesToMove.add(currentPositionToMove);
          } else {
            placesToMove.add(currentPositionToMove);
            break;
          }
        } else {
          break;
        }
      }
    }

    return placesToMove;
  }

  static List<int> _getAllBishopPlaceToMove(
    int currentBishopPosition,
    List<Solider> allSoldiersList,
  ) {
    List<int> placesToMove = [];
    placesToMove.insertAll(
      0,
      _getAllBishopPlaceToMoveDownLeft(currentBishopPosition, allSoldiersList),
    );

    placesToMove.insertAll(
      0,
      _getAllBishopPlaceToMoveDownRight(currentBishopPosition, allSoldiersList),
    );

    placesToMove.insertAll(
      0,
      _getAllBishopPlaceToMoveBackLeft(currentBishopPosition, allSoldiersList),
    );

    placesToMove.insertAll(
      0,
      _getAllBishopPlaceToMoveBackRight(currentBishopPosition, allSoldiersList),
    );

    return placesToMove;
  }

  static List<int> _getAllQueenMoves(
    int currentQueenPosition,
    Board allSoldiersList,
  ) {
    List<int> placesToMove = [];
    placesToMove.addAll(
      _getAllBishopPlaceToMove(
        currentQueenPosition,
        allSoldiersList.getChessBoardList(),
      ),
    );
    placesToMove.addAll(
      _placesToMoveRook(currentQueenPosition, allSoldiersList),
    );
    placesToMove = placesToMove.where((sold) => sold != -1).toList();

    return placesToMove;
  }

  static List<int> _getAllFrontPlacesKnightMoves(
    int currentKnightPosition,
    List<Solider> allSoldiersList,
  ) {
    List<int> placesToMove = [];
    int currentPositionToMove = -1;
    SoliderType currentPositionToMoveType = SoliderType.none;
    if (PositionsValidations.onBottom(currentKnightPosition)) {
      return [];
    }
    if (!PositionsValidations.atEndsRows(currentKnightPosition)) {
      currentPositionToMove = currentKnightPosition + 17; //t
      if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
        currentPositionToMoveType =
            allSoldiersList[currentPositionToMove].soliderType;

        if (PositionsValidations.isPlaceHasNoSoldier(
          currentPositionToMoveType,
        )) {
          placesToMove.add(currentPositionToMove);
          currentPositionToMove = -1;
        }
      }
    }

    if (!PositionsValidations.atStartsRows(currentKnightPosition)) {
      currentPositionToMove = currentKnightPosition + 15; //t
      if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
        currentPositionToMoveType =
            allSoldiersList[currentPositionToMove].soliderType;

        if (PositionsValidations.isPlaceHasNoSoldier(
          currentPositionToMoveType,
        )) {
          placesToMove.add(currentPositionToMove);
          currentPositionToMove = -1;
        }
      }
    }

    return placesToMove;
  }

  static List<int> _getAllBackPlacesKnightMoves(
    int currentKnightPosition,
    List<Solider> allSoldiersList,
  ) {
    List<int> placesToMove = [];
    int currentPositionToMove = 0;
    SoliderType currentPositionToMoveType = SoliderType.none;
    if (PositionsValidations.onTop(currentKnightPosition)) {
      return [];
    }

    if (!PositionsValidations.atStartsRows(currentKnightPosition)) {
      currentPositionToMove = currentKnightPosition - 17; //t
      if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
        currentPositionToMoveType =
            allSoldiersList[currentPositionToMove].soliderType;

        if (PositionsValidations.isPlaceHasNoSoldier(
          currentPositionToMoveType,
        )) {
          placesToMove.add(currentPositionToMove);
          currentPositionToMove = 0;
        }
      }
    }

    if (!PositionsValidations.atEndsRows(currentKnightPosition)) {
      currentPositionToMove = currentKnightPosition - 15; //t
      if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
        currentPositionToMoveType =
            allSoldiersList[currentPositionToMove].soliderType;

        if (PositionsValidations.isPlaceHasNoSoldier(
          currentPositionToMoveType,
        )) {
          placesToMove.add(currentPositionToMove);
          currentPositionToMove = 0;
        }
      }
    }

    return placesToMove;
  }

  static List<int> _getAllLeftPlacesKnightMoves(
    int currentKnightPosition,
    List<Solider> allSoldiersList,
  ) {
    List<int> placesToMove = [];
    int currentPositionToMove = 0;
    SoliderType currentPositionToMoveType = SoliderType.none;

    if (!PositionsValidations.atStartsRows(currentKnightPosition)) {
      if (!PositionsValidations.onBottom(currentKnightPosition)) {
        if (PositionsValidations.notOnSecondColumn(currentKnightPosition)) {
          currentPositionToMove = currentKnightPosition + 6; //t
          if (PositionsValidations.validSoldierPosiiton(
            currentPositionToMove,
          )) {
            currentPositionToMoveType =
                allSoldiersList[currentPositionToMove].soliderType;

            if (PositionsValidations.isPlaceHasNoSoldier(
              currentPositionToMoveType,
            )) {
              placesToMove.add(currentPositionToMove);
              currentPositionToMove = 0;
            }
          }
        }
      }
    }

    if (!PositionsValidations.atStartsRows(currentKnightPosition)) {
      if (!PositionsValidations.onTop(currentKnightPosition)) {
        if (PositionsValidations.notOnSecondColumn(currentKnightPosition)) {
          currentPositionToMove = currentKnightPosition - 8 - 2; //t
          if (PositionsValidations.validSoldierPosiiton(
            currentPositionToMove,
          )) {
            currentPositionToMoveType =
                allSoldiersList[currentPositionToMove].soliderType;

            if (PositionsValidations.isPlaceHasNoSoldier(
              currentPositionToMoveType,
            )) {
              placesToMove.add(currentPositionToMove);
              currentPositionToMove = 0;
            }
          }
        }
      }
    }

    return placesToMove;
  }

  static List<int> _getAllRightPlacesKnightMoves(
    int currentKnightPosition,
    List<Solider> allSoldiersList,
  ) {
    List<int> placesToMove = [];
    int currentPositionToMove = 0;
    SoliderType currentPositionToMoveType = SoliderType.none;

    if (!PositionsValidations.atEndsRows(currentKnightPosition)) {
      if (!PositionsValidations.onBottom(currentKnightPosition)) {
        if (PositionsValidations.notOnSeventhColumn(currentKnightPosition)) {
          currentPositionToMove = currentKnightPosition + 10; //t
          if (PositionsValidations.validSoldierPosiiton(
            currentPositionToMove,
          )) {
            currentPositionToMoveType =
                allSoldiersList[currentPositionToMove].soliderType;

            if (PositionsValidations.isPlaceHasNoSoldier(
              currentPositionToMoveType,
            )) {
              placesToMove.add(currentPositionToMove);
              currentPositionToMove = 0;
            }
          }
        }
      }
    }

    if (!PositionsValidations.atEndsRows(currentKnightPosition)) {
      if (!PositionsValidations.onTop(currentKnightPosition)) {
        if (PositionsValidations.notOnSeventhColumn(currentKnightPosition)) {
          currentPositionToMove = currentKnightPosition - 6; //t
          if (PositionsValidations.validSoldierPosiiton(
            currentPositionToMove,
          )) {
            currentPositionToMoveType =
                allSoldiersList[currentPositionToMove].soliderType;

            if (PositionsValidations.isPlaceHasNoSoldier(
              currentPositionToMoveType,
            )) {
              placesToMove.add(currentPositionToMove);
              currentPositionToMove = 0;
            }
          }
        }
      }
    }

    return placesToMove;
  }

  static List<int> _getAllKinghtMoves(
    int currentKnightPosition,
    List<Solider> allSoldiersList,
  ) {
    List<int> placesToMove = [];
    placesToMove.addAll(
      _getAllFrontPlacesKnightMoves(currentKnightPosition, allSoldiersList),
    );

    placesToMove.addAll(
      _getAllBackPlacesKnightMoves(currentKnightPosition, allSoldiersList),
    );

    placesToMove.addAll(
      _getAllLeftPlacesKnightMoves(currentKnightPosition, allSoldiersList),
    );

    placesToMove.addAll(
      _getAllRightPlacesKnightMoves(currentKnightPosition, allSoldiersList),
    );

    return placesToMove;
  }

  static int _getKingFrontPosition(
    int currentkingPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentkingPosition) ||
        PositionsValidations.onBottom(currentkingPosition)) {
      return -1;
    }
    int placeToMove = currentkingPosition + 8;

    if (PositionsValidations.validSoldierPosiiton(placeToMove)) {
      SoliderType placeToMoveSoldierType =
          allSoldiersList[placeToMove].soliderType;
      if (PositionsValidations.isPlaceHasNoSoldier(placeToMoveSoldierType)) {
        return placeToMove;
      }
    }

    return -1;
  }

  static int _getKingBackPosition(
    int currentkingPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentkingPosition) ||
        PositionsValidations.onTop(currentkingPosition)) {
      return -1;
    }
    int placeToMove = currentkingPosition - 8;

    if (PositionsValidations.validSoldierPosiiton(placeToMove)) {
      SoliderType placeToMoveSoldierType =
          allSoldiersList[placeToMove].soliderType;
      if (PositionsValidations.isPlaceHasNoSoldier(placeToMoveSoldierType)) {
        return placeToMove;
      }
    }

    return -1;
  }

  static List<int> _getAllKingLeftMoves(
    int currentkingPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentkingPosition) ||
        PositionsValidations.atStartsRows(currentkingPosition)) {
      return [];
    }

    List<int> placesToMove = [];
    int currentPositionToMove = -1;
    SoliderType currentPositionToMoveSoldierType = SoliderType.none;
    currentPositionToMove = currentkingPosition - 9;
    if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
      currentPositionToMoveSoldierType =
          allSoldiersList[currentPositionToMove].soliderType;
      if (PositionsValidations.isPlaceHasNoSoldier(
        currentPositionToMoveSoldierType,
      )) {
        placesToMove.add(currentPositionToMove);
      }
    }

    currentPositionToMove = currentkingPosition - 1;
    if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
      currentPositionToMoveSoldierType =
          allSoldiersList[currentPositionToMove].soliderType;
      if (PositionsValidations.isPlaceHasNoSoldier(
        currentPositionToMoveSoldierType,
      )) {
        placesToMove.add(currentPositionToMove);
      }
    }

    currentPositionToMove = currentkingPosition + 7;
    if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
      currentPositionToMoveSoldierType =
          allSoldiersList[currentPositionToMove].soliderType;
      if (PositionsValidations.isPlaceHasNoSoldier(
        currentPositionToMoveSoldierType,
      )) {
        placesToMove.add(currentPositionToMove);
      }
    }
    return placesToMove;
  }

  static List<int> _getAllKingRightMoves(
    int currentkingPosition,
    List<Solider> allSoldiersList,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(currentkingPosition) ||
        PositionsValidations.atEndsRows(currentkingPosition)) {
      return [];
    }

    List<int> placesToMove = [];
    int currentPositionToMove = -1;
    SoliderType currentPositionToMoveSoldierType = SoliderType.none;
    currentPositionToMove = currentkingPosition - 7;
    if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
      currentPositionToMoveSoldierType =
          allSoldiersList[currentPositionToMove].soliderType;
      if (PositionsValidations.isPlaceHasNoSoldier(
        currentPositionToMoveSoldierType,
      )) {
        placesToMove.add(currentPositionToMove);
      }
    }

    currentPositionToMove = currentkingPosition + 1;
    if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
      currentPositionToMoveSoldierType =
          allSoldiersList[currentPositionToMove].soliderType;
      if (PositionsValidations.isPlaceHasNoSoldier(
        currentPositionToMoveSoldierType,
      )) {
        placesToMove.add(currentPositionToMove);
      }
    }

    currentPositionToMove = currentkingPosition + 9;
    if (PositionsValidations.validSoldierPosiiton(currentPositionToMove)) {
      currentPositionToMoveSoldierType =
          allSoldiersList[currentPositionToMove].soliderType;
      if (PositionsValidations.isPlaceHasNoSoldier(
        currentPositionToMoveSoldierType,
      )) {
        placesToMove.add(currentPositionToMove);
      }
    }
    return placesToMove;
  }

  static List<int> _getAllKingMoves(
    int currentkingPosition,
    List<Solider> allSoldiersList,
  ) {
    List<int> placesToMove = [];
    placesToMove.add(
      _getKingFrontPosition(currentkingPosition, allSoldiersList),
    );

    placesToMove.add(
      _getKingBackPosition(currentkingPosition, allSoldiersList),
    );

    placesToMove.addAll(
      _getAllKingLeftMoves(currentkingPosition, allSoldiersList),
    );

    placesToMove.addAll(
      _getAllKingRightMoves(currentkingPosition, allSoldiersList),
    );

    placesToMove = placesToMove.where((pose) => pose != -1).toList();

    return placesToMove;
  }

  static Board swapBoardSoldiers(
    Board board,
    int locationToMove,
    int currentPosition,
  ) {
    Solider locationToMoveSoldier = board.getChessBoardList()[locationToMove];
    Solider currentLocationSoldier = board.getChessBoardList()[currentPosition];

    currentLocationSoldier.soliderposition = locationToMove;
    locationToMoveSoldier.soliderposition = currentPosition;

    board.getChessBoardList()[locationToMove] = currentLocationSoldier;
    board.getChessBoardList()[currentPosition] = locationToMoveSoldier;

    currentLocationSoldier.firstMove = false;

    return board;
  }

  static Board move(Board board, int locationToMove, int position, bool turn) {
    SoliderType type = board.getChessBoardList()[position].soliderType;
    if (type == SoliderType.none) return board;

    bool isfirstmove = board.getChessBoardList()[position].firstMove;
    List<int> locations = getAllSoldierMoves(
      position,
      type,
      board,
      turn,
      isfirstmove,
    );

    if (board.getChessBoardList().isNotEmpty) {
      if (locations.contains(locationToMove)) {
        board = swapBoardSoldiers(board, locationToMove, position);
      }
    }

    return board;
  }

  static List<int> getAllSoldierMoves(
    int position,
    SoliderType type,
    Board board,
    bool turn,
    bool isfirstmove,
  ) {
    if (!PositionsValidations.validSoldierPosiiton(position)) {
      return [];
    }
    List<int> moves = [];
    switch (type) {
      case SoliderType.pawn:
        moves = _placesToMovePawn(isfirstmove, board, turn, position);
      case SoliderType.rock:
        moves = _placesToMoveRook(position, board);
      case SoliderType.bishop:
        moves = _getAllBishopPlaceToMove(position, board.getChessBoardList());
      case SoliderType.queen:
        moves = _getAllQueenMoves(position, board);
      case SoliderType.knight:
        moves = _getAllKinghtMoves(position, board.getChessBoardList());

      case SoliderType.king:
        moves = _getAllKingMoves(position, board.getChessBoardList());

      case SoliderType.none:
        moves = [];
    }

    return moves;
  }
}
