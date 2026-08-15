import 'package:chess_app_v1/Models/solider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:chess_app_v1/Providers/board_provider.dart';

class KilledPieceWidget extends ConsumerWidget {
  const KilledPieceWidget({
    super.key,
    required this.playerID,
    required this.gameID,
    required this.isWhite,
  });
  final int playerID;
  final int gameID;
  final bool isWhite;
  Icon setIcon(SoliderType type, bool isWhite) {
    final IconData iconData = switch (type) {
      SoliderType.king => MdiIcons.chessKing,
      SoliderType.queen => MdiIcons.chessQueen,
      SoliderType.knight => MdiIcons.chessKnight,
      SoliderType.rock => MdiIcons.chessRook,
      SoliderType.bishop => MdiIcons.chessBishop,
      SoliderType.pawn => MdiIcons.chessPawn,
      SoliderType.none => MdiIcons.abTesting,
    };
    return Icon(
      iconData,
      size: 25,
      color: type != SoliderType.none
          ? (isWhite ? Colors.white : Colors.black)
          : Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(boardGameProvider(gameID));
    List<Solider> killedSoldiers = gameState.board.getPlayerkilledSoldiers(
      playerID,
    );
    return Container(
      height: 50,
      width: double.infinity,

      //color: Colors.red,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 8,
        children: [
          for (int i = 0; i < killedSoldiers.length; i++)
            _killedSoldierIcon(killedSoldiers[i]),
        ],
      ),
    );
  }

  Widget _killedSoldierIcon(Solider killedSoldiers) {
    return Container(
      height: 20,
      width: 15,
      child: setIcon(killedSoldiers.soliderType, isWhite),
    );
  }
}
