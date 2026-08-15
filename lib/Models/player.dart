import 'package:chess_app_v1/Models/solider.dart';
import 'package:chess_app_v1/Validations/positions_validations.dart';

enum ColorType { white, black }

class Player {
  final int id;
  final Solider king;
  final List<Solider> queen;
  final ColorType color;
  bool turn;
  final String playerTitle;
  int remainingTime ;

  // Grouped piece positions
  final List<Solider> pawns; // Expects 8 items.
  final List<Solider> rooks; // Expects 2 items.
  final List<Solider> horses; // Expects 2 items.
  final List<Solider> bishops; // Expects 2 items.
  int promotable;
  static Player getEmptyInstance() {
    return Player(
      id: 0,
      playerTitle: '',
      king: Solider.getEmptyInstance(),
      queen: [],
      color: ColorType.black,
      turn: false,
      pawns: [],
      rooks: [],
      horses: [],
      bishops: [],
      promotable: -1,
      remainingTime: 0
    );
  }

  Player clone() {
    List<Solider> sold = [];
    for (int i = 0; i < pawns.length; i++) {
      sold.add(pawns[i].clone());
    }
    int promotableClone = promotable;
    return Player(
      id: id,
      playerTitle: playerTitle,
      king: king.clone(),
      queen: List.generate(queen.length, (i) => queen[i].clone()),
      color: color,
      turn: turn,
      pawns: sold,
      rooks: List.generate(rooks.length, (i) => rooks[i].clone()),
      horses: List.generate(horses.length, (i) => horses[i].clone()),
      bishops: List.generate(bishops.length, (i) => bishops[i].clone()),
      promotable: promotableClone,
      remainingTime:  remainingTime
    );
  }

  List<int> _getAllPawnCkeckers() {
    List<int> checkersPawnID = [];
    for (int i = 0; i < pawns.length; i++) {
      if (pawns[i].checker) {
        if (PositionsValidations.validSoldierPosiiton(
          pawns[i].soliderposition,
        )) {
          checkersPawnID.add(pawns[i].soliderID);
        }
      }
    }

    return checkersPawnID;
  }

  List<int> _getAllRookCkeckers() {
    List<int> checkersRookID = [];
    for (int i = 0; i < rooks.length; i++) {
      if (rooks[i].checker) {
        if (PositionsValidations.validSoldierPosiiton(
          rooks[i].soliderposition,
        )) {
          checkersRookID.add(rooks[i].soliderID);
        }
      }
    }

    return checkersRookID;
  }

  List<int> _getKingAndQueenChecks() {
    List<int> checkersKingAndQueenID = [];
    for (int i = 0; i < queen.length; i++) {
      if (PositionsValidations.validSoldierPosiiton(queen[i].soliderposition) &&
          queen[i].checker) {
        checkersKingAndQueenID.add(queen[i].soliderID);
      }
    }

    if (king.checker) {
      checkersKingAndQueenID.add(king.soliderID);
    }
    return checkersKingAndQueenID;
  }

  List<int> _getAllbishopsCkeckers() {
    List<int> checkersBishopsID = [];
    for (int i = 0; i < bishops.length; i++) {
      if (bishops[i].checker) {
        if (PositionsValidations.validSoldierPosiiton(
          bishops[i].soliderposition,
        )) {
          checkersBishopsID.add(bishops[i].soliderID);
        }
      }
    }

    return checkersBishopsID;
  }

  List<int> _getAllknightCkeckers() {
    List<int> checkersknightsID = [];
    for (int i = 0; i < horses.length; i++) {
      if (horses[i].checker) {
        if (PositionsValidations.validSoldierPosiiton(
          horses[i].soliderposition,
        )) {
          checkersknightsID.add(horses[i].soliderID);
        }
      }
    }

    return checkersknightsID;
  }

  List<Solider> getAllSoldiers() {
    List<Solider> allSoldiers = [];
    allSoldiers.addAll(pawns);
    allSoldiers.addAll(bishops);
    allSoldiers.add(king);
    allSoldiers.addAll(rooks);
    allSoldiers.addAll(horses);
    allSoldiers.addAll(queen);

    return allSoldiers;
  }

  List<Solider> getPlayerSoldiers() {
    List<Solider> allPlayerSoldiers = [];

    allPlayerSoldiers.addAll(
      bishops.where(
        (s) => PositionsValidations.validSoldierPosiiton(s.soliderposition),
      ),
    );
    allPlayerSoldiers.addAll(
      rooks.where(
        (s) => PositionsValidations.validSoldierPosiiton(s.soliderposition),
      ),
    );
    allPlayerSoldiers.addAll(
      pawns.where(
        (s) => PositionsValidations.validSoldierPosiiton(s.soliderposition),
      ),
    );
    allPlayerSoldiers.addAll(
      horses.where(
        (s) => PositionsValidations.validSoldierPosiiton(s.soliderposition),
      ),
    );
    allPlayerSoldiers.addAll(
      queen.where(
        (s) => PositionsValidations.validSoldierPosiiton(s.soliderposition),
      ),
    );

    allPlayerSoldiers.add(king);

    return allPlayerSoldiers;
  }

  List<int> getAllCheckersSoldier() {
    List<int> checkersID = [];
    checkersID.addAll(_getAllPawnCkeckers());
    checkersID.addAll(_getAllRookCkeckers());
    checkersID.addAll(_getAllbishopsCkeckers());
    checkersID.addAll(_getAllknightCkeckers());
    checkersID.addAll(_getKingAndQueenChecks());
    return checkersID;
  }

  Player({
    required this.id,
    required this.playerTitle,
    required this.king,
    required this.queen,
    required this.color,
    required this.turn,
    required this.pawns,
    required this.rooks,
    required this.horses,
    required this.bishops,
    required this.promotable,
    required this.remainingTime
  });
}
