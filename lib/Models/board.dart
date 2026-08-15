import 'package:chess_app_v1/Models/Game.dart';
import 'package:chess_app_v1/Models/player.dart';
import 'package:chess_app_v1/Models/solider.dart';
import 'package:chess_app_v1/Validations/positions_validations.dart';

class Board {
  List<Solider> _chessBoard = List.filled(64, Solider.getEmptyInstance());
  List<Solider> _killSoldiers = [];
  int player1KingPosition = -2;
  int player2kingPosition = -2;

  Game game;
  Solider selectedSoldier = Solider.getEmptyInstance();
  static Board getEmptyInstance() {
    return Board(game: Game.getEmptyInstance());
  }

  Board clone() {
    return Board(game: this.game.clone());
  }

  Board({required this.game}) {
    _fillChessBoard();
  }

  void changeSelectedSoldier(Solider solider) {
    selectedSoldier = solider;
  }

  List<Solider> getChessBoardList() {
    return _chessBoard;
  }

  void _fillKilledSoldiers(Solider killedSoldiers) {
    if (killedSoldiers.soliderType != SoliderType.none) {
      _killSoldiers.add(killedSoldiers);
    }
  }

  List<Solider> getPlayerkilledSoldiers(int playerID) {
    List<Solider> killedSoldiers = [];
    if (_killSoldiers.isNotEmpty) {
      killedSoldiers = _killSoldiers
          .where(
            (solider) =>
                solider.soliderposition == -1 && solider.playerID == playerID,
          )
          .toList();
    }

    return killedSoldiers;
  }

  List<Solider> getallkilledSoldiers(int playerOneID, int playerTwoID) {
    List<Solider> killedSoldiers = [];
    if (_killSoldiers.isNotEmpty) {
      killedSoldiers = _killSoldiers
          .where(
            (solider) =>
                (solider.soliderposition == -1 &&
                    solider.playerID == playerOneID) ||
                (solider.soliderposition == -1 &&
                    solider.playerID == playerTwoID),
          )
          .toList();
    }

    return killedSoldiers;
  }

  bool _soldierIsKilled(Solider killedSolider) {
    return _killSoldiers.contains(killedSolider);
  }

  void setKilledSoldier(Solider killedSolider) {
    if (!_soldierIsKilled(killedSolider)) {
      _killSoldiers.add(killedSolider);
    }
  }

  void _fillChessBoard() {
    _fillPlayerOneAndPlayerTwoKingsPositions(game.playerOne, game.playerTwo);
    _fillPlayerOneAndPlayerTwoKingAndQueen(game.playerOne, game.playerTwo);
    _fillPlayerOneAndPlayerTwoPawns(game.playerOne, game.playerTwo);
    _fillPlayerOneAndPlayerTwoRocks(game.playerOne, game.playerTwo);
    _fillPlayerOneAndPlayerTwobishops(game.playerOne, game.playerTwo);
    _fillPlayerOneAndPlayerTwoHorses(game.playerOne, game.playerTwo);

    // printChessBoard(game);
  }

  void editKingPosition(int kingPosition, bool whichPlayer) {
    if (!PositionsValidations.validSoldierPosiiton(kingPosition)) {
      return;
    }
    if (whichPlayer) {
      player1KingPosition = kingPosition;
    } else {
      player2kingPosition = kingPosition;
    }
  }

  void _fillPlayerOneAndPlayerTwoKingsPositions(
    Player player1,
    Player player2,
  ) {
    player1KingPosition = player1.king.soliderposition > -1
        ? player1.king.soliderposition
        : -2;
    player2kingPosition = player2.king.soliderposition > -1
        ? player2.king.soliderposition
        : -2;
  }

  void _fillPlayerOneAndPlayerTwoKingAndQueen(Player player1, Player player2) {
    if (_chessBoard.isNotEmpty) {
     
      if (PositionsValidations.validSoldierPosiiton(
        player1.king.soliderposition,
      )) {
        _chessBoard[player1.king.soliderposition] = player1.king;
      }

      for (int i = 0; i < player1.queen.length; i++) {
        if (player1.queen[i].soliderposition > -1) {
          _chessBoard[player1.queen[i].soliderposition] = player1.queen[i];
        } else {
          _fillKilledSoldiers(player1.queen[i]);
        }
      }

      for (int i = 0; i < player1.queen.length; i++) {
        if ((player1.king.soliderposition != player2.king.soliderposition) &&
            (player1.queen[i].soliderposition !=
                player2.queen[i].soliderposition)) {
          _chessBoard[player2.king.soliderposition] = player2.king;
          if (player2.queen[i].soliderposition > -1) {
            _chessBoard[player2.queen[i].soliderposition] = player2.queen[i];
          } else {
            _fillKilledSoldiers(player2.queen[i]);
          }
        }
      }
    }
  }

  void _fillPlayerOneAndPlayerTwoPawns(Player player1, Player player2) {
    if (player1.pawns.isNotEmpty) {
      for (int i = 0; i < player1.pawns.length; i++) {
        if (player1.pawns[i].soliderposition > -1) {
          _chessBoard[player1.pawns[i].soliderposition] = player1.pawns[i];
        } else {
          _fillKilledSoldiers(player1.pawns[i]);
        }
      }
    }
    if (player2.pawns.isNotEmpty) {
      for (int i = 0; i < player2.pawns.length; i++) {
        if (player2.pawns[i].soliderposition > -1) {
          _chessBoard[player2.pawns[i].soliderposition] = player2.pawns[i];
        } else {
          _fillKilledSoldiers(player2.pawns[i]);
        }
      }
    }
  }

  void _fillPlayerOneAndPlayerTwoRocks(Player player1, Player player2) {
    if (player1.rooks.isNotEmpty) {
      for (int i = 0; i < player1.rooks.length; i++) {
        if (player1.rooks[i].soliderposition > -1) {
          _chessBoard[player1.rooks[i].soliderposition] = player1.rooks[i];
        } else {
          _fillKilledSoldiers(player1.rooks[i]);
        }
      }
    }
    if (player2.rooks.isNotEmpty) {
      for (int i = 0; i < player2.rooks.length; i++) {
        if (player2.rooks[i].soliderposition > -1) {
          _chessBoard[player2.rooks[i].soliderposition] = player2.rooks[i];
        } else {
          _fillKilledSoldiers(player2.rooks[i]);
        }
      }
    }
  }

  void _fillPlayerOneAndPlayerTwobishops(Player player1, Player player2) {
    if (player1.bishops.isNotEmpty) {
      for (int i = 0; i < player1.bishops.length; i++) {
        if (player1.bishops[i].soliderposition > -1) {
          _chessBoard[player1.bishops[i].soliderposition] = player1.bishops[i];
        } else {
          _fillKilledSoldiers(player1.bishops[i]);
        }
      }
    }
    if (player2.bishops.isNotEmpty) {
      for (int i = 0; i < player2.bishops.length; i++) {
        if (player2.bishops[i].soliderposition > -1) {
          _chessBoard[player2.bishops[i].soliderposition] = player2.bishops[i];
        } else {
          _fillKilledSoldiers(player2.bishops[i]);
        }
      }
    }
  }

  void _fillPlayerOneAndPlayerTwoHorses(Player player1, Player player2) {
    if (player1.horses.isNotEmpty) {
      for (int i = 0; i < player1.horses.length; i++) {
        if (player1.horses[i].soliderposition > -1) {
          _chessBoard[player1.horses[i].soliderposition] = player1.horses[i];
        } else {
          _fillKilledSoldiers(player1.horses[i]);
        }
      }
    }
    if (player2.horses.isNotEmpty) {
      for (int i = 0; i < player2.horses.length; i++) {
        if (player2.horses[i].soliderposition > -1) {
          _chessBoard[player2.horses[i].soliderposition] = player2.horses[i];
        } else {
          _fillKilledSoldiers(player2.horses[i]);
        }
      }
    }
  }
}
