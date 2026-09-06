import 'package:chess_app_v1/Models/board.dart';
import 'package:chess_app_v1/Models/player.dart';
import 'package:chess_app_v1/DataBase/chess_db.dart';
import 'package:chess_app_v1/Models/solider.dart';

class Game {
  Game({
    required this.gameID,
    required this.playerOne,
    required this.playerTwo,
    required this.dateOfStart,
    required this.winner,
    required this.playerOneTitle,
    required this.playerTwoTitle,
    required this.chekcedKing,
    this.mode = 0,
    this.aiIsPlayerOne = false,
    this.playerOneRemainingTime = 0,
    this.playerTowRemainingTime = 0,
    this.timeControlMinutes = 0,
  });

  final int gameID;
  Player playerOne;
  Player playerTwo;
  final DateTime dateOfStart;
  final String playerOneTitle;
  final String playerTwoTitle;
  int winner;
  int chekcedKing = 0;
  int mode = 0;

  // True when the computer controls playerOne (white) instead of playerTwo.
  // In a vs-computer game exactly one side is the AI; this flag picks which.
  bool aiIsPlayerOne = false;
  int playerOneRemainingTime;
  int playerTowRemainingTime;

  // Original time control in minutes per side (0 = open/no timer). Persisted
  // so a rematch can reproduce the same time control.
  int timeControlMinutes;

  static Game getEmptyInstance() {
    return Game(
      gameID: -1,
      playerOne: Player.getEmptyInstance(),
      playerTwo: Player.getEmptyInstance(),
      dateOfStart: DateTime.now(),
      winner: 0,
      playerOneTitle: '',
      playerTwoTitle: '',
      chekcedKing: 0,
      mode: 0,
      timeControlMinutes: 0,
    );
  }

  Game clone() {
    return Game(
      gameID: gameID,
      playerOne: playerOne.clone(),
      playerTwo: playerTwo.clone(),
      dateOfStart: dateOfStart,
      winner: winner,
      playerOneTitle: playerOneTitle,
      playerTwoTitle: playerTwoTitle,
      chekcedKing: chekcedKing,
      mode: mode,
      aiIsPlayerOne: aiIsPlayerOne,
      timeControlMinutes: timeControlMinutes,
    );
  }

  void checkKing(int whichKing) {
    whichKing == 1
        ? chekcedKing = 1
        : whichKing == 2
        ? chekcedKing = 2
        : chekcedKing = 0;
  }

  void unCheckedKing() {
    chekcedKing = 0;
  }

  static Future<int> addNewGame(
    String player1Title,
    String player2Title,
    bool isVsComputer,
    int player1Time,
    int player2Time, {
    bool aiIsPlayerOne = false,
  }) async {
    Player player1 = Player(
      id: 0,
      playerTitle: player1Title,
      promotable: -1,
      king: Solider(
        soliderID: 0,
        soliderType: SoliderType.king,
        soliderposition: 3,
        playerID: 0,
        firstMove: false,
      ),
      queen: [
        Solider(
          soliderID: 0,
          soliderType: SoliderType.queen,
          soliderposition: 4,
          playerID: 0,
          firstMove: false,
        ),
      ],
      color: ColorType.white,
      turn: true,
      pawns: List.generate(
        8,
        (index) => Solider(
          soliderID: 0,
          soliderType: SoliderType.pawn,
          soliderposition: index + 8,
          playerID: 0,
          firstMove: true,
        ),
      ),
      rooks: [
        Solider(
          soliderID: 0,
          soliderType: SoliderType.rock,
          soliderposition: 0,
          playerID: 0,
          firstMove: false,
        ),
        Solider(
          soliderID: 0,
          soliderType: SoliderType.rock,
          soliderposition: 7,
          playerID: 0,
          firstMove: false,
        ),
      ],
      horses: [
        Solider(
          soliderID: 0,
          soliderType: SoliderType.knight,
          soliderposition: 1,
          playerID: 0,
          firstMove: false,
        ),
        Solider(
          soliderID: 0,
          soliderType: SoliderType.knight,
          soliderposition: 6,
          playerID: 0,
          firstMove: false,
        ),
      ],
      bishops: [
        Solider(
          soliderID: 0,
          soliderType: SoliderType.bishop,
          soliderposition: 2,
          playerID: 0,
          firstMove: false,
        ),
        Solider(
          soliderID: 0,
          soliderType: SoliderType.bishop,
          soliderposition: 5,
          playerID: 0,
          firstMove: false,
        ),
      ],
      remainingTime: player1Time * 60,
    );

    Player player2 = Player(
      id: 0,
      playerTitle: player2Title,
      promotable: -1,
      king: Solider(
        soliderID: 0,
        soliderType: SoliderType.king,
        soliderposition: 59,
        playerID: 0,
        firstMove: false,
      ),
      queen: [
        Solider(
          soliderID: 0,
          soliderType: SoliderType.queen,
          soliderposition: 60,
          playerID: 0,
          firstMove: false,
        ),
      ],
      color: ColorType.black,
      turn: false,
      pawns: List.generate(
        8,
        (index) => Solider(
          soliderID: 0,
          soliderType: SoliderType.pawn,
          soliderposition: index + 48,
          playerID: 0,
          firstMove: true,
        ),
      ),
      rooks: [
        Solider(
          soliderID: 0,
          soliderType: SoliderType.rock,
          soliderposition: 56,
          playerID: 0,
          firstMove: false,
        ),
        Solider(
          soliderID: 0,
          soliderType: SoliderType.rock,
          soliderposition: 63,
          playerID: 0,
          firstMove: false,
        ),
      ],
      horses: [
        Solider(
          soliderID: 0,
          soliderType: SoliderType.knight,
          soliderposition: 57,
          playerID: 0,
          firstMove: false,
        ),
        Solider(
          soliderID: 0,
          soliderType: SoliderType.knight,
          soliderposition: 62,
          playerID: 0,
          firstMove: false,
        ),
      ],
      bishops: [
        Solider(
          soliderID: 0,
          soliderType: SoliderType.bishop,
          soliderposition: 58,
          playerID: 0,
          firstMove: false,
        ),
        Solider(
          soliderID: 0,
          soliderType: SoliderType.bishop,
          soliderposition: 61,
          playerID: 0,
          firstMove: false,
        ),
      ],
      remainingTime: player2Time * 60,
    );

    Game newGame = Game(
      gameID: 0,
      playerOneTitle: player1Title,
      playerTwoTitle: player2Title,
      playerOne: player1,
      playerTwo: player2,
      dateOfStart: DateTime.now(),
      winner: -1,
      chekcedKing: 0,
      mode: isVsComputer ? 1 : 0,
      aiIsPlayerOne: aiIsPlayerOne,
      timeControlMinutes: player1Time,
    );

    int newGameID = await ChessDb.addNewGame(newGame);
    return newGameID;
  }

  Solider getPawnByID(int soldierID, bool turn, Board board) {
    if (soldierID >= 0) {
      Solider solider = board.getChessBoardList().firstWhere(
        (s) => s.soliderID == soldierID,
      );

      return solider;
    }
    return Solider.getEmptyInstance();
  }
}
