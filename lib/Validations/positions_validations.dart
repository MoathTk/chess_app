import 'package:chess_app_v1/Models/solider.dart';

class PositionsValidations {
  static bool validSoldierPosiiton(int position) {
    return (position <= 63 && position >= 0);
  }

  static bool notOnSecondColumn(int position) {
    List<int> secondColumn = [1, 9, 17, 25, 33, 41, 49, 57];
    return !secondColumn.contains(position);
  }

  static bool notOnSeventhColumn(int position) {
    List<int> seventhColumn = [6, 14, 22, 30, 38, 46, 54, 62];
    return !seventhColumn.contains(position);
  }

  static bool areIdsEquavilant(int firstID, int secondID) {
    return firstID == secondID;
  }

  static bool onTop(int position) {
    return (position >= 0 && position <= 7);
  }

  static bool onBottom(int position) {
    return (position >= 56 && position <= 63);
  }

  static bool isPlaceHasNoSoldier(SoliderType solderType) {
    return (solderType == SoliderType.none);
  }

  static bool atEndsRows(int currentPosition) {
    List<int> endRows = [7, 15, 23, 31, 39, 47, 55, 63];
    return endRows.contains(currentPosition);
  }

  static bool atStartsRows(int currentPosition) {
    List<int> startRows = [0, 8, 16, 24, 32, 40, 48, 56];
    return startRows.contains(currentPosition);
  }

  static bool isSoldierOnTop(int currentPosition, bool turn) {
    return turn
        ? (currentPosition >= 56 && currentPosition <= 63)
        : (currentPosition >= 0 && currentPosition <= 7);
  }

  static bool isPawnOnleftSide(int currentPosition) {
    List<int> edges = [0, 8, 16, 24, 32, 40, 48, 56];

    return edges.contains(currentPosition);
  }

  static bool isPawnOnRightSide(int currentPosition) {
    List<int> edges = [7, 15, 23, 31, 39, 47, 55, 63];
    return edges.contains(currentPosition);
  }

  static bool accessedEdges(int position) {
    return (PositionsValidations.atEndsRows(position) ||
        PositionsValidations.atStartsRows(position));
  }

  static bool pawnReachedEnd(bool turn, int position) {
    bool reachedEnd = false;
    if (onBottom(position) && turn) {
      reachedEnd = true;
    } else if (onTop(position) && !turn) {
      reachedEnd = true;
    }
    return reachedEnd;
  }
}
