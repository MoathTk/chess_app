import 'package:chess_app_v1/Models/solider.dart';

class ComputerTurn {
  final Solider currentSoldier;
  final bool type;
  final int where;
  final bool turn;

  ComputerTurn({
    required this.currentSoldier,
    required this.turn,
    required this.type,
    required this.where,
  });
}
