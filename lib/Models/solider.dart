enum SoliderType { king, queen, pawn, rock, knight, bishop, none }

class Solider {
  final int soliderID;
  SoliderType soliderType;
  int soliderposition;
  final int playerID;
  bool firstMove;
  bool checker;

  Solider({
    required this.soliderID,
    required this.soliderType,
    required this.soliderposition,
    required this.playerID,
    required this.firstMove,
    this.checker = false,
  });
  Solider clone() {
    return Solider(
      soliderID: soliderID,
      soliderType: soliderType,
      soliderposition: soliderposition,
      playerID: playerID,
      firstMove: firstMove,
      checker: checker,
    );
  }

  static Solider getEmptyInstance() {
    return Solider(
      soliderID: -1,
      soliderType: SoliderType.none,
      soliderposition: -3,
      playerID: -1,
      firstMove: false,
    );
  }
}
