import 'package:chess_app_v1/Backend/kill_Logic.dart';
import 'package:chess_app_v1/Models/board.dart';
import 'package:chess_app_v1/DataBase/chess_db.dart' as db;
import 'package:chess_app_v1/Backend/chess_clock.dart';
import 'package:chess_app_v1/Backend/computer_logic.dart';
import 'package:chess_app_v1/Backend/move_logic.dart';

import 'package:chess_app_v1/Models/Game.dart';
import 'package:chess_app_v1/Models/computer_turn.dart';

import 'package:chess_app_v1/Models/player.dart';
import 'package:chess_app_v1/Models/solider.dart';

import 'package:chess_app_v1/Screens/game_screen.dart';

import 'dart:async';

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
  BoardNotifier(super.gameboard) {
    _initClock();
    // If a resumed vs-computer game is already waiting on the AI's move,
    // kick it off (e.g. a hot restart mid-game).
    if (_isAiTurn) {
      playComputerTurn();
    }
  }

  // Per-player seconds-ticking chess clock. Null when neither player has a
  // time control (legacy games), in which case no timer ever runs.
  ChessClock? _clock;
  Timer? _clockTimer;

  // True when the current game was decided by a flag fall (timeout) rather
  // than checkmate. Read by the UI to label the victory dialog.
  bool timedOut = false;

  // True while the computer is "thinking" (its delayed turn is in flight).
  // The UI reads this to block the human from tapping during the AI's move.
  bool aiThinking = false;

  // Whether the computer controls playerOne. In a vs-computer game exactly one
  // side is the AI; game.aiIsPlayerOne tells us which.
  bool get _isAiTurn =>
      (state.board.game.mode == 1) &&
      !isGameOver &&
      (_isP1Turn() == state.board.game.aiIsPlayerOne);

  bool _isP1Turn() => state.currentTurn == 0;

  void _initClock() {
    _clock = ChessClock(
      playerOneTime: state.board.game.playerOne.remainingTime,
      playerTwoTime: state.board.game.playerTwo.remainingTime,
    );
    if (!isGameOver && (_clock?.isRunning ?? false)) {
      _startClock();
    }
  }

  void _startClock() {
    _clockTimer ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
  }

  void _stopClock() {
    _clockTimer?.cancel();
    _clockTimer = null;
  }

  @override
  void dispose() {
    _stopClock();
    super.dispose();
  }

  // Writes the authoritative clock seconds back into the Player objects so
  // the UI and the database reads always mirror the running clock.
  void _syncClockToPlayers() {
    final ChessClock? clock = _clock;
    if (clock == null) return;
    state.board.game.playerOne.remainingTime = clock.playerOneTime;
    state.board.game.playerTwo.remainingTime = clock.playerTwoTime;
  }

  void _tick() {
    // Once a winner is decided (checkmate or timeout) the clocks freeze.
    if (isGameOver) {
      _stopClock();
      return;
    }
    final int winner = _clock?.tick(_isP1Turn()) ?? -1;
    _syncClockToPlayers();
    if (winner == 0 || winner == 1) {
      _onTimeout(winner);
      return;
    }
    // Persist the active player's clock every second so a hot restart resumes
    // at the exact remaining time; the idle player's time only changes at a
    // move boundary, where it is already saved in changeCurrentTurn.
    final Player active = _isP1Turn()
        ? state.board.game.playerOne
        : state.board.game.playerTwo;
    db.ChessDb.updateRemainingTime(active.id, active.remainingTime);
    state = state.copyWith(board: state.board);
  }

  void _onTimeout(int winner) {
    timedOut = true;
    _stopClock();
    state.board.game.winner = winner;
    state = state.copyWith(board: state.board);

    // The player whose clock hit zero loses; persist zero for them and the
    // result for the game so the finish survives a restart.
    final int loserID = winner == 0
        ? state.board.game.playerTwo.id
        : state.board.game.playerOne.id;
    db.ChessDb.setGameWinner(state.board.game.gameID, winner);
    db.ChessDb.updateRemainingTime(loserID, 0);
  }

  // The game is over as soon as a winner is decided: winner == 0 means
  // playerOne (white) won, winner == 1 means playerTwo (black) won.
  bool get isGameOver =>
      state.board.game.winner == 0 || state.board.game.winner == 1;

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
    _syncClockToPlayers();
    int newTurn = state.currentTurn == 0 ? 1 : 0;

    state.board.game.playerTwo.turn = newTurn == 1;
    state.board.game.playerOne.turn = newTurn == 0;

    state = state.copyWith(currentTurn: newTurn);

    db.ChessDb.changeTurn(
      newTurn,
      state.board.game.playerOne.id,
      state.board.game.playerTwo.id,
    );
    // Persist both clocks here so a restart from a move boundary (or a clock
    // that fired concurrently with this move) resumes correctly. The active
    // clock is additionally saved every second in _tick.
    db.ChessDb.updateRemainingTime(
      state.board.game.playerOne.id,
      state.board.game.playerOne.remainingTime,
    );
    db.ChessDb.updateRemainingTime(
      state.board.game.playerTwo.id,
      state.board.game.playerTwo.remainingTime,
    );

    // After the turn passes, if it is now the computer's turn, let it play
    // (with a short delay so the human sees the move happen).
    if (_isAiTurn) {
      playComputerTurn();
    }
  }

  // Picks and executes one random-but-legal move for the computer side, then
  // auto-promotes any pawn the AI just advanced to the final rank. Runs after
  // a short delay so the move is visible; reuses moveSolider/killSoldier so
  // all DB, check/checkmate and clock handling applies to the AI identically.
  Future<void> playComputerTurn() async {
    if (!_isAiTurn) return;
    if (aiThinking) return;
    aiThinking = true;
    state = state.copyWith(board: state.board);

    await Future<void>.delayed(const Duration(milliseconds: 700));

    // The game may have finished (e.g. the human resigned) during the delay.
    if (!_isAiTurn) {
      aiThinking = false;
      return;
    }

    Player side = state.board.game.aiIsPlayerOne
        ? state.board.game.playerOne
        : state.board.game.playerTwo;
    ComputerTurn? turn = ComputerLogic.determineAll(state.board, side);
    if (turn == null) {
      aiThinking = false;
      return;
    }

    state = state.copyWith(
      currentTouchedIndex: turn.currentSoldier.soliderposition,
      placesToMove: turn.type ? [] : [turn.where],
      placesToKill: turn.type ? [turn.where] : [],
    );

    if (turn.type) {
      killSoldier(turn.where);
    } else {
      moveSolider(turn.where);
    }

    // Auto-promote only a pawn belonging to the AI side. The human's pending
    // promotion (should one exist) is handled by their own dialog.
    bool aiIsPlayerOne = side.id == state.board.game.playerOne.id;
    int aiSideIndex = aiIsPlayerOne ? 1 : 2;
    if (hasToPromotePawn() == aiSideIndex) {
      await promotePawnInDatabase(SoliderType.queen);
    }

    aiThinking = false;
    state = state.copyWith(currentTouchedIndex: -1, board: state.board);
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
          board = await _resolveCheckState(board, _isP1Turn());
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

  // After the moving side completes a move, (re)evaluate whether its pieces
  // give check. Scanning the whole side (not just the moved piece) is what
  // makes discovered checks and promotion mates produce a winner: when the
  // mover opens a line or is promoted into a queen/bishop, the piece actually
  // attacking the king is NOT the same one that the move validation saw.
  Future<Board> _resolveCheckState(
    Board updatedBoard,
    bool currentTurn,
  ) async {
    Player moverSide = currentTurn
        ? updatedBoard.game.playerOne
        : updatedBoard.game.playerTwo;
    int targetKing = currentTurn ? 2 : 1;

    List<Solider> sidePieces = moverSide.getPlayerSoldiers();
    int anyCheckedKing = 0;

    for (int i = 0; i < sidePieces.length; i++) {
      Solider piece = sidePieces[i];
      if (!PositionsValidations.validSoldierPosiiton(
        piece.soliderposition,
      )) {
        continue;
      }
      int checking = CheckLogic.isSoldierMayAttacksKings(
        piece.soliderposition,
        updatedBoard,
        targetKing,
      );
      bool givesCheck = checking != 0;
      if (givesCheck) {
        anyCheckedKing = checking;
      }
      // Keep the checker flags in sync (memory + DB) so checkmate evaluation
      // and the escape filtering see exactly the pieces covering the king.
      if (givesCheck != piece.checker) {
        if (givesCheck) {
          bool setted = await _setSoldierAsCheckerInDB(
            piece.soliderID,
            piece.playerID,
          );
          if (setted) {
            updatedBoard
                .getChessBoardList()[piece.soliderposition]
                .checker = true;
          }
        } else {
          bool unSetted = await _unSetSoldierAsCheckerInDB(
            piece.soliderID,
            piece.playerID,
          );
          if (unSetted) {
            updatedBoard
                .getChessBoardList()[piece.soliderposition]
                .checker = false;
          }
        }
      }
    }

    updatedBoard.game.checkKing(anyCheckedKing);

    if (anyCheckedKing != 0 &&
        CheckLogic.checkMate(!currentTurn, updatedBoard.clone())) {
      // The player who just moved delivered the checkmate, so they win.
      // winner 0 = playerOne (white), winner 1 = playerTwo (black).
      updatedBoard.game.winner = currentTurn ? 0 : 1;
      // Persist the result so the game stays finished after a restart.
      await db.ChessDb.setGameWinner(
        updatedBoard.game.gameID,
        updatedBoard.game.winner,
      );
    }

    return updatedBoard;
  }

  void moveSolider(int positionToMove) async {
    // Once the game is over no moves are allowed.
    if (isGameOver) return;
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
        int selectedIndex = state.currentTouchedIndex;

        // Detect a castling move: the selected piece is a king and the target
        // square is two squares away on the same rank.
        bool isCastling = false;
        int rookDestination = -1;
        if (state.board.getChessBoardList()[selectedIndex].soliderType ==
            SoliderType.king) {
          if ((positionToMove - selectedIndex).abs() == 2 &&
              positionToMove ~/ 8 == selectedIndex ~/ 8) {
            bool kingSide = positionToMove > selectedIndex;
            rookDestination =
                kingSide ? selectedIndex + 1 : selectedIndex - 1;
            isCastling = true;
          }
        }

        Board updatedBoard = isCastling
            ? MoveLogic.castling(
                state.board,
                selectedIndex,
                positionToMove,
                currentTurn,
              )
            : MoveLogic.move(
                state.board,
                positionToMove,
                selectedIndex,
                currentTurn,
              );

        if (state.placesToMove.contains(positionToMove)) {
          // For castling we must persist both the king and the rook, since the
          // move relocates two pieces.
          bool movedKing = await _moveSoldierInDataBase(
            updatedBoard.getChessBoardList()[positionToMove],
          );
          bool movedRook = true;
          if (isCastling) {
            movedRook = await _moveSoldierInDataBase(
              updatedBoard.getChessBoardList()[rookDestination],
            );
          }
          if (movedKing && movedRook) {
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

            // Only pass the turn if the game is still running; after a
            // checkmate the game is over and there is no one to move.
            if (!isGameOver) {
              changeCurrentTurn();
            }
          }
        }
      }
    }
  }

  void killSoldier(int positionToKill) async {
    // Once the game is over no captures are allowed.
    if (isGameOver) return;
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
            // Only pass the turn if the game is still running; after a
            // checkmate the game is over.
            if (!isGameOver) {
              changeCurrentTurn();
            }
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

      // When the selected piece is a king, the generated moves may include
      // castling destinations. Castling is only legal if the king does not pass
      // through (or land on) an attacked square, so filter those squares out.
      if (state.board.getChessBoardList()[index].soliderType ==
          SoliderType.king) {
        bool turn = state.board.game.playerOne.turn;
        int moverPlayerID =
            state.board.getChessBoardList()[index].playerID;

        placesToMove = placesToMove.where((move) {
          // A castling destination is exactly two squares away on the same row.
          if ((move - index).abs() == 2 &&
              move ~/ 8 == index ~/ 8) {
            return CheckLogic.isCastlePathSafe(
              state.board,
              index,
              move,
              moverPlayerID,
              turn,
            );
          }
          return true;
        }).toList();
      }
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
    // Once the game is over no piece may be selected.
    if (isGameOver) return;
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
