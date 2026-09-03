import 'package:chess_app_v1/Backend/kill_Logic.dart';
import 'package:chess_app_v1/Models/board.dart';
import 'package:chess_app_v1/DataBase/chess_db.dart' as db;
import 'package:chess_app_v1/Backend/move_logic.dart';

import 'package:chess_app_v1/Models/Game.dart';

import 'package:chess_app_v1/Models/solider.dart';

import 'package:chess_app_v1/Screens/game_screen.dart';

import 'package:flutter_riverpod/legacy.dart';
import 'package:chess_app_v1/Backend/check_logic.dart';
import 'package:chess_app_v1/Validations/positions_validations.dart';

class GameBoardState {
  Board board;
  int currentTouchedIndex;
  List<int> placesToMove;
  List<int> placesToKill;
  int movedFromIndex;
  int movedToIndex;

  int currentTurn;
  GameBoardState({
    required this.board,
    required this.currentTouchedIndex,
    required this.currentTurn,
    required this.placesToMove,

    required this.placesToKill,
    required this.movedFromIndex,
    required this.movedToIndex,
  });

  GameBoardState copyWith({
    Board? board,
    int? currentTouchedIndex,
    List<int>? placesToMove,
    int? currentTurn,
    List<int>? placesToKill,
    int? movedFromIndex,
    int? movedToIndex,
  }) {
    return GameBoardState(
      board: board ?? this.board,
      currentTouchedIndex: currentTouchedIndex ?? this.currentTouchedIndex,
      placesToMove: placesToMove ?? this.placesToMove,
      currentTurn: currentTurn ?? this.currentTurn,
      placesToKill: placesToKill ?? this.placesToKill,
      movedFromIndex: movedFromIndex ?? this.movedFromIndex,
      movedToIndex: movedToIndex ?? this.movedToIndex,
    );
  }
}

class BoardNotifier extends StateNotifier<GameBoardState> {
  BoardNotifier(super.gameboard);

  bool _isP1Turn() => state.currentTurn == 0;

  int _opponentKing() => _isP1Turn() ? 2 : 1;

  int hasToPromotePawn() {
    Game currentGame = state.board.game;
    if (currentGame.playerOne.promotable >= 0) {
      return 1;
    } else if (currentGame.playerTwo.promotable >= 0) {
      return 2;
    }
    return -1;
  }

  void changeCurrentTurn() {
    int newTurn = state.currentTurn == 0 ? 1 : 0;

    state.board.game.playerTwo.turn = newTurn == 1;
    state.board.game.playerOne.turn = newTurn == 0;

    state = state.copyWith(currentTurn: newTurn);

    db.ChessDb.changeTurn(
      newTurn,
      state.board.game.playerOne.id,
      state.board.game.playerTwo.id,
    );
    //must implement the computer moves logic.
    //_AITurn();
  }

  static Future<bool> _moveSoldierInDataBase(Solider soldierToMove) async {
    bool moved = false;

    try {
      moved = await db.ChessDb.moveSoldier(soldierToMove);
    } catch (e) {
      return false;
    }
    return moved;
  }

  static Future<bool> _setPawnAsMustPromote(Solider pawnToPromote) async {
    bool promoted = false;
    try {
      promoted = await db.ChessDb.pawnMustBePromoted(pawnToPromote);
    } catch (e) {
      promoted = false;
    }
    return promoted;
  }

  Future<bool> _setPawnAsMustPromoteToPlayer(
    Solider pawnToPromote,
    bool currentTurn,
  ) async {
    bool promoted = false;
    if (PositionsValidations.pawnReachedEnd(
      currentTurn,
      pawnToPromote.soliderposition,
    )) {
      promoted = await _setPawnAsMustPromote(pawnToPromote);
      if (promoted) {
        {
          Board updatedBoard = state.board;
          currentTurn
              ? updatedBoard.game.playerOne.promotable =
                    pawnToPromote.soliderposition
              : updatedBoard.game.playerTwo.promotable =
                    pawnToPromote.soliderposition;
          state = state.copyWith(board: updatedBoard);
        }
      }
    }

    return promoted;
  }

  Future<bool> _unSetPawnAsMustPromoteToPlayer(
    Solider pawnToPromote,
    bool currentTurn,
  ) async {
    bool unPromoted = false;

    unPromoted = await db.ChessDb.depawnMustBePromoted(pawnToPromote.playerID);
    if (unPromoted) {
      {
        Board updatedBoard = state.board;
        currentTurn
            ? updatedBoard.game.playerOne.promotable = -1
            : updatedBoard.game.playerTwo.promotable = -1;
        state = state.copyWith(board: updatedBoard);
      }
    }

    return unPromoted;
  }

  int _getPromotablePawnID() {
    int pawnID = -1;
    if (state.board.game.playerOne.promotable >= 0) {
      pawnID = state.board
          .getChessBoardList()[state.board.game.playerOne.promotable]
          .soliderID;
    }
    if (state.board.game.playerTwo.promotable >= 0) {
      pawnID = state.board
          .getChessBoardList()[state.board.game.playerTwo.promotable]
          .soliderID;
    }

    return pawnID;
  }

  Future<bool> promotePawnInDatabase(SoliderType typeToPromote) async {
    bool promoted = false;
    int pawnID = _getPromotablePawnID();

    Solider pawnToPromote = state.board.game.getPawnByID(
      pawnID,
      _isP1Turn(),
      state.board,
    );

    try {
      promoted = await db.ChessDb.promotePawn(pawnToPromote, typeToPromote);
      if (promoted) {
        bool dePromotedFromPlayerInDB = await _unSetPawnAsMustPromoteToPlayer(
          pawnToPromote,
          _isP1Turn(),
        );
        if (dePromotedFromPlayerInDB) {
          Board board = state.board;
          board.getChessBoardList()[pawnToPromote.soliderposition].soliderType =
              typeToPromote;
          board.game.playerOne.promotable = -1;
          board.game.playerTwo.promotable = -1;
          state = state.copyWith(board: board);
        }
      }
    } catch (e) {
      promoted = false;
    }
    return promoted;
  }

  Future<bool> deletepromotablePlayerInDatabase(int playerID) async {
    bool dePromoted = false;
    try {
      dePromoted = await db.ChessDb.depawnMustBePromoted(playerID);
    } catch (e) {
      dePromoted = false;
    }
    return dePromoted;
  }

  static Future<bool> _killSoldierInDataBase(
    Solider soliderTokill,
    Solider killerSolider,
  ) async {
    bool moved = false;

    try {
      moved = await db.ChessDb.killSoldier(soliderTokill, killerSolider);
    } catch (e) {
      return false;
    }
    return moved;
  }

  static Future<bool> _setSoldierAsCheckerInDB(
    int soldierID,
    int playerID,
  ) async {
    bool checked = false;

    try {
      checked = await db.ChessDb.setSoldierAsChecker(soldierID, playerID);
    } catch (e) {
      return false;
    }
    return checked;
  }

  static Future<bool> _unSetSoldierAsCheckerInDB(
    int soldierID,
    int playerID,
  ) async {
    bool unChecked = false;

    try {
      unChecked = await db.ChessDb.unSetSoldierAsChecker(soldierID, playerID);
    } catch (e) {
      return false;
    }
    return unChecked;
  }

  Board _setPromotedPawnInGameBoard(
    Board board,
    bool currentTurn,
    int pawnPosition,
  ) {
    if (currentTurn) {
      board.game.playerOne.promotable = board
          .getChessBoardList()[pawnPosition]
          .soliderposition;
    } else {
      board.game.playerTwo.promotable = board
          .getChessBoardList()[pawnPosition]
          .soliderposition;
    }
    state = state.copyWith(board: board);
    return board;
  }

  Future<Board> _resolveCheckState(
    Board updatedBoard,
    Solider mover,
    bool currentTurn,
  ) async {
    int checked = CheckLogic.isSoldierMayAttacksKings(
      mover.soliderposition,
      updatedBoard,
      _opponentKing(),
    );
    updatedBoard.game.checkKing(checked);

    if (checked == 1 || checked == 2) {
      if (CheckLogic.checkMate(!currentTurn, updatedBoard.clone())) {
        updatedBoard.game.winner = currentTurn ? 0 : 1;
      }
      bool setted = await _setSoldierAsCheckerInDB(
        mover.soliderID,
        mover.playerID,
      );
      if (setted) {
        updatedBoard.getChessBoardList()[mover.soliderposition].checker = true;
      }
    } else {
      bool unSetted = await _unSetSoldierAsCheckerInDB(
        mover.soliderID,
        mover.playerID,
      );
      if (unSetted) {
        updatedBoard.getChessBoardList()[mover.soliderposition].checker = false;
      }
    }

    return updatedBoard;
  }

  void moveSolider(int positionToMove) async {
    if (PositionsValidations.validSoldierPosiiton(state.currentTouchedIndex) &&
        PositionsValidations.validSoldierPosiiton(positionToMove)) {
      int previous = state.currentTouchedIndex;
      int next = positionToMove;

      bool currentTurn = state.currentTurn == 0 ? true : false;
      if (CheckLogic.willMoveCauseCheckedKing(
        state.currentTouchedIndex,
        positionToMove,
        currentTurn
            ? state.board.game.playerOne.id
            : state.board.game.playerTwo.id,
        currentTurn,
        state.board.clone(),
      )) {
        Board updatedBoard = MoveLogic.move(
          state.board,
          positionToMove,
          state.currentTouchedIndex,
          currentTurn,
        );

        if (state.placesToMove.contains(positionToMove)) {
          bool moved = await _moveSoldierInDataBase(
            updatedBoard.getChessBoardList()[positionToMove],
          );
          if (moved) {
            Solider movedSoldier = updatedBoard
                .getChessBoardList()[positionToMove];
            if (movedSoldier.soliderType == SoliderType.king) {
              updatedBoard.editKingPosition(positionToMove, currentTurn);
            }

            updatedBoard.getChessBoardList()[positionToMove].firstMove = false;
            state = state.copyWith(
              board: updatedBoard,
              currentTouchedIndex: -1,
              placesToMove: [],
              placesToKill: [],
              movedFromIndex: previous,
              movedToIndex: next,
            ); //Moath12-#4ieo#
            //await AudioService.playRingBell();
            updatedBoard = await _resolveCheckState(
              updatedBoard,
              movedSoldier,
              currentTurn,
            );
            state = state.copyWith(board: updatedBoard);
            if (movedSoldier.soliderType == SoliderType.pawn &&
                PositionsValidations.pawnReachedEnd(
                  currentTurn,
                  movedSoldier.soliderposition,
                )) {
              bool promoted = await _setPawnAsMustPromoteToPlayer(
                movedSoldier,
                currentTurn,
              );
              if (promoted) {
                _setPromotedPawnInGameBoard(
                  state.board,
                  currentTurn,
                  movedSoldier.soliderposition,
                );
              }
            }

            changeCurrentTurn();
          }
        }
      }
    }
  }

  void killSoldier(int positionToKill) async {
    if (PositionsValidations.validSoldierPosiiton(state.currentTouchedIndex) &&
        PositionsValidations.validSoldierPosiiton(positionToKill)) {
      int previous = state.currentTouchedIndex;
      int next = positionToKill;

      bool currentTurn = state.currentTurn == 0 ? true : false;
      if (CheckLogic.willNotKillCauseCheckedKingOrAboutToBeKilled(
        state.currentTouchedIndex,
        positionToKill,
        state.currentTurn == 0
            ? state.board.game.playerOne.id
            : state.board.game.playerTwo.id,
        currentTurn,
        state.board.clone(),
      )) {
        Solider killedSolider = state.board.getChessBoardList()[positionToKill];
        Solider killerSolider = state.board
            .getChessBoardList()[state.currentTouchedIndex];

        Board updatedBoard = KillLogic.killSoldier(
          state.currentTouchedIndex,
          state.board,
          currentTurn,
          positionToKill,
        );

        if (state.placesToKill.contains(positionToKill)) {
          bool killed = await _killSoldierInDataBase(
            killedSolider,
            killerSolider,
          );
          if (killed) {
            // CheckLogic.checkMate(!currentTurn, updatedBoard.clone());
            state = state.copyWith(
              board: updatedBoard,
              placesToKill: [],
              placesToMove: [],
              movedFromIndex: previous,
              movedToIndex: next,
            );
            killerSolider = updatedBoard.getChessBoardList()[positionToKill];

            updatedBoard = await _resolveCheckState(
              updatedBoard,
              killerSolider,
              currentTurn,
            );
            state = state.copyWith(board: updatedBoard);
            if (killerSolider.soliderType == SoliderType.pawn) {
              bool promoted = await _setPawnAsMustPromoteToPlayer(
                killerSolider,
                currentTurn,
              );
              if (promoted) {
                _setPromotedPawnInGameBoard(
                  state.board,
                  currentTurn,
                  killerSolider.soliderposition,
                );
              }
            }
            changeCurrentTurn();
          }
        }
      }
    }
  }

  List<int> getMovesForIndex(int index) {
    List<int> placesToMove = [];
    int anyKingChecked = state.board.game.chekcedKing;

    if (PositionsValidations.validSoldierPosiiton(index)) {
      List<Solider> checkers = state.board
          .getChessBoardList()
          .where(
            (e) =>
                (e.checker &&
                e.playerID != state.board.getChessBoardList()[index].playerID),
          )
          .toList();

      placesToMove = CheckLogic.willMovePreventKilling(
        index,
        state.board.getChessBoardList()[index].soliderID,
        anyKingChecked == 0 ? [] : checkers.map((e) => e.soliderID).toList(),
        state.board,
      );
    }

    return placesToMove;
  }

  List<int> getKillsForIndex(int index) {
    List<int> placesToKill = [];
    int anyKingChecked = state.board.game.chekcedKing;
    if (PositionsValidations.validSoldierPosiiton(index)) {
      if (anyKingChecked == 1) {
        placesToKill = CheckLogic.willKillPreventKilling(
          index,
          state.board.getChessBoardList()[index].soliderID,

          state.board.game.playerTwo.getAllCheckersSoldier(),
          state.board,
        );
      } else if (anyKingChecked == 2) {
        placesToKill = CheckLogic.willKillPreventKilling(
          index,
          state.board.getChessBoardList()[index].soliderID,

          state.board.game.playerOne.getAllCheckersSoldier(),
          state.board,
        );
      } else {
        List<int> checkersID = state.currentTurn == 0
            ? state.board.game.playerTwo.getAllCheckersSoldier()
            : state.board.game.playerOne.getAllCheckersSoldier();
        placesToKill = CheckLogic.willKillPreventKilling(
          index,
          state.board.getChessBoardList()[index].soliderID,
          checkersID,
          state.board,
        );
      }
    }

    return placesToKill;
  }

  void selectIndex(int index) {
    state = state.copyWith(
      currentTouchedIndex: index,
      placesToMove: getMovesForIndex(index),
      placesToKill: getKillsForIndex(index),
    );
  }
}

final boardGameProvider = StateNotifierProvider.autoDispose
    .family<BoardNotifier, GameBoardState, int>((ref, gameID) {
      Game game = games.firstWhere((game) => game.gameID == gameID);
      Board newBoard = Board(game: game);
      return BoardNotifier(
        GameBoardState(
          board: newBoard, // Initialize your board
          currentTouchedIndex: -1,
          currentTurn: game.playerOne.turn ? 0 : 1,
          placesToMove: [],

          placesToKill: [],
          movedFromIndex: -1,
          movedToIndex: -1,
        ),
      );
    });
