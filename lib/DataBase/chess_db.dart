import 'package:chess_app_v1/Models/solider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:chess_app_v1/Models/Game.dart';
import 'package:chess_app_v1/Models/player.dart';
import 'package:chess_app_v1/Validations/positions_validations.dart';

class ChessDb {
  static Database? _database;

  static Future<Database> initDB(String databaseTitle) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseTitle);

    return openDatabase(path, version: 1, onCreate: _createDataBase);
  }

  static getInctence() async {
    _database ??= await initDB("chess.db");
    return _database;
  }

  static Future<void> _createDataBase(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await _createGameTable(db, version);
    await _createPlayerTable(db, version);
    await _createSoldierTable(db, version);
  }

  static Future<bool> moveSoldier(Solider soldier) async {
    return await _moveSoldier(soldier);
  }

  static Future<bool> _moveSoldier(Solider solider) async {
    bool moved = false;
    _database ??= await getInctence();
    final isMoved = await _database!.update(
      'Soldier',
      {'Position': solider.soliderposition, 'FirstMove': 0},
      where: 'ID = ? AND PlayerID = ?',
      whereArgs: [solider.soliderID, solider.playerID],
    );
    moved = isMoved > 0;

    return moved;
  }

  static Future<bool> _saveGame(Game game) async {
    _database ??= await getInctence();
    final saved = await _database!.update(
      'Game',
      {'winner': game.winner},
      where: 'ID = ? ',
      whereArgs: [game.gameID],
    );

    return saved > 0;
  }

  static Future<bool> whichPlayerWon(bool whichPlayer, int gameID) async {
    _database ??= await getInctence();
    final set = await _database!.update(
      "Game",
      {"winner": whichPlayer ? 1 : 2},
      where: "ID = ?",
      whereArgs: [gameID],
    );
    return set > 0;
  }

  // Stores the result of a finished game. The winner value follows the
  // in-memory convention: 0 = playerOne (white), 1 = playerTwo (black),
  // -1 = game still running.
  static Future<bool> setGameWinner(int gameID, int winner) async {
    _database ??= await getInctence();
    final set = await _database!.update(
      "Game",
      {"winner": winner},
      where: "ID = ?",
      whereArgs: [gameID],
    );
    return set > 0;
  }

  static Future<void> _saveAllPlayerSoldiers(Player player) async {
    _database ??= await getInctence();
    for (int i = 0; i < player.pawns.length; i++) {
      await _database!.update(
        'Soldier',
        {'Position': player.pawns[i].soliderposition},
        where: 'ID = ? AND PlayerID = ?',
        whereArgs: [player.pawns[i].soliderID, player.id],
      );
    }
  }

  static int _getSoldierTypeNumber(SoliderType solderType) {
    int type = 3;
    if (solderType == SoliderType.queen) {
      type = 2;
    } else if (solderType == SoliderType.bishop) {
      type = 6;
    } else if (solderType == SoliderType.rock) {
      type = 4;
    } else if (solderType == SoliderType.knight) {
      type = 5;
    }

    return type;
  }

  static Future<bool> pawnMustBePromoted(Solider pawn) async {
    int position = pawn.soliderposition;
    if (!PositionsValidations.validSoldierPosiiton(position)) {
      return false;
    }

    _database ??= await getInctence();
    int set = 0;
    set = await _database!.update(
      'Player',
      {'Promotable': position},
      where: 'ID = ?',
      whereArgs: [pawn.playerID],
    );

    return set > 0;
  }

  static Future<bool> depawnMustBePromoted(int playerID) async {
    if (playerID < 0) {
      return false;
    }
    _database ??= await getInctence();
    int set = 0;
    set = await _database!.update(
      'Player',
      {'Promotable': -1},
      where: 'ID = ?',
      whereArgs: [playerID],
    );

    return set > 0;
  }

  static Future<bool> promotePawn(
    Solider pawn,
    SoliderType typeToPromote,
  ) async {
    int type = _getSoldierTypeNumber(typeToPromote);
    if (type == 3) {
      return false;
    }
    _database ??= await getInctence();
    int promoted = 0;
    int position = pawn.soliderposition;
    int id = pawn.soliderID;

    if (PositionsValidations.validSoldierPosiiton(position)) {
      promoted = await _database!.update(
        'Soldier',
        {'type': type},
        where: 'ID = ? AND PlayerID = ?',
        whereArgs: [id, pawn.playerID],
      );
      return promoted > 0;
    }
    return false;
  }

  static Future<bool> saveAllGameChanges(Game game) async {
    return await _saveGame(game);
  }

  static Future<bool> killSoldier(
    Solider killedSolider,
    Solider killerSolider,
  ) async {
    return (await _killSoldier(killedSolider) &&
        await moveSoldier(killerSolider));
  }

  static Future<bool> _killSoldier(Solider solider) async {
    bool moved = false;
    _database ??= await getInctence();
    final isMoved = await _database!.update(
      'Soldier',
      {'Position': -1},
      where: 'ID = ? AND PlayerID = ?',
      whereArgs: [solider.soliderID, solider.playerID],
    );
    moved = isMoved > 0;

    return moved;
  }

  static Future<void> changeTurn(
    int turn,
    int playerOneID,
    int playerTowID,
  ) async {
    await _changeTurn(turn == 0 ? true : false, playerOneID);
    await _changeTurn(turn == 1 ? true : false, playerTowID);
  }

  static Future<bool> _changeTurn(bool turn, int playerID) async {
    _database ??= await getInctence();
    final changed = await _database!.update(
      'Player',
      {'Turn': turn ? 1 : 0},
      where: 'ID = ? ',
      whereArgs: [playerID],
    );
    return changed > 0;
  }

  // Persists a player's remaining clock time (in seconds) so a game can be
  // resumed with the correct clock after a restart. A value of 0 means the
  // player has no clock (legacy/unlimited games never run a timer).
  static Future<void> updateRemainingTime(
    int playerID,
    int remainingSeconds,
  ) async {
    if (playerID < 0) return;
    _database ??= await getInctence();
    await _database!.update(
      'Player',
      {'RemainingTime': remainingSeconds},
      where: 'ID = ? ',
      whereArgs: [playerID],
    );
  }

  static Future<List<Game>> getAllUserGames() async {
    _database ??= await initDB("chess.db");

    List<Map<String, dynamic>> games = await _database!.query('Game');

    List<Future<Game?>> avGames = List.generate(games.length, (index) async {
      final gamePlayers = await _getGamePlayersByID(games[index]['ID']);

      if (gamePlayers.length < 2) {
        return null;
      }

      return Game(
        gameID: games[index]['ID'],
        playerOneTitle: gamePlayers[0].playerTitle,
        playerTwoTitle: gamePlayers[1].playerTitle,
        playerOne: gamePlayers[0],
        playerTwo: gamePlayers[1],
        dateOfStart: DateTime.now(),
        // Load the stored result so finished games stay finished after a
        // restart. The column uses the in-memory convention: 0 = playerOne
        // (white), 1 = playerTwo (black), -1 = still running.
        winner: games[index]['winner'] ?? -1,
        chekcedKing: gamePlayers[0].getAllCheckersSoldier().isNotEmpty
            ? 2
            : gamePlayers[1].getAllCheckersSoldier().isNotEmpty
            ? 1
            : 0,
        mode: games[index]['mode'],
        // Legacy rows store NULL here; treat as open/no timer (0).
        timeControlMinutes:
            int.tryParse(games[index]['timer']?.toString() ?? '') ?? 0,
      );
    });
    List<Game?> allGames = await Future.wait(avGames);
    return allGames.whereType<Game>().toList();
  }

  static Future<List<Player>> _getGamePlayersByID(int gameID) async {
    List<Player> playersList = [];
    List<Map<String, dynamic>> players = await _database!.query(
      'Player',
      where: 'GameID = ?',
      whereArgs: [gameID],
    );

    // CHANGE THIS LINE: Only proceed if we found at least 2 players
    if (players.length >= 2) {
      for (int i = 0; i < 2; i++) {
        List<Solider> allPawns = await _getAllPlayerIDPawns(players[i]['ID']);

        List<Solider> allRockes = await _getAllPlayerIDRocks(players[i]['ID']);
        List<Solider> allKinghts = await _getAllPlayerIDKnights(
          players[i]['ID'],
        );
        List<Solider> allbishops = await _getAllPlayerIDBishops(
          players[i]['ID'],
        );
        Solider? king = await _getPlayerIDKing(players[i]['ID']);
        List<Solider>? queen = await _getPlayerIDQueen(players[i]['ID']);
        playersList.add(
          Player(
            id: players[i]['ID'],
            playerTitle: players[i]['PlayerTitle']?.toString() ?? "Guest",
            king: king!,
            queen: queen,
            color: int.parse(players[i]['Color'].toString()) == 1
                ? ColorType.white
                : ColorType.black,
            turn: players[i]['Turn'] != 0,
            pawns: allPawns,
            rooks: allRockes,
            horses: allKinghts,
            bishops: allbishops,
            promotable: players[i]['Promotable'],
            // Legacy games created before the clock feature store NULL here,
            // which we treat as "no timer" (0). New games persist the seconds.
            remainingTime: players[i]['RemainingTime'] ?? 0,
          ),
        );
      }
    }

    return playersList;
  }

  static Future<List<Solider>> _getAllPlayerIDPawns(int playerID) async {
    List<Map<String, dynamic>> allPawns = await _database!.query(
      'Soldier',
      where: 'PlayerID = ? AND  Type = ?',
      whereArgs: [playerID, 3],
    );
    List<Solider> pawns = allPawns.map((pwan) {
      return Solider(
        soliderID: pwan['ID'],
        soliderType: SoliderType.pawn,
        soliderposition: pwan['Position'],
        playerID: playerID,
        firstMove: pwan['FirstMove'] == 0 ? false : true,
        checker: pwan['Checker'] == 0 ? false : true,
      );
    }).toList();

    return pawns;
  }

  static Future<List<Solider>> _getAllPlayerIDRocks(int playerID) async {
    List<Map<String, dynamic>> allRockes = await _database!.query(
      'Soldier',
      where: 'PlayerID = ? AND  Type = ?',
      whereArgs: [playerID, 4],
    );
    List<Solider> rocks = allRockes.map((rook) {
      return Solider(
        soliderID: rook['ID'],
        soliderType: SoliderType.rock,
        soliderposition: rook['Position'],
        playerID: playerID,
        // Track whether the rook has moved (needed for castling eligibility).
        firstMove: rook['FirstMove'] == 0 ? false : true,
        checker: rook['Checker'] == 0 ? false : true,
      );
    }).toList();

    return rocks;
  }

  static Future<List<Solider>> _getAllPlayerIDKnights(int playerID) async {
    List<Map<String, dynamic>> allKinghts = await _database!.query(
      'Soldier',
      where: 'PlayerID = ? AND  Type = ?',
      whereArgs: [playerID, 5],
    );
    List<Solider> kinghts = allKinghts.map((knight) {
      return Solider(
        soliderID: knight['ID'],
        soliderType: SoliderType.knight,
        soliderposition: knight['Position'],
        playerID: playerID,
        firstMove: false,
        checker: knight['Checker'] == 0 ? false : true,
      );
    }).toList();

    return kinghts;
  }

  static Future<List<Solider>> _getAllPlayerIDBishops(int playerID) async {
    List<Map<String, dynamic>> allPawns = await _database!.query(
      'Soldier',
      where: 'PlayerID = ? AND  Type = ?',
      whereArgs: [playerID, 6],
    );
    List<Solider> pawns = allPawns.map((bishop) {
      return Solider(
        soliderID: bishop['ID'],
        soliderType: SoliderType.bishop,
        soliderposition: bishop['Position'],
        playerID: playerID,
        firstMove: false,
        checker: bishop['Checker'] == 0 ? false : true,
      );
    }).toList();

    return pawns;
  }

  static Future<Solider?> _getPlayerIDKing(int playerID) async {
    List<Map<String, dynamic>> playerking = await _database!.query(
      'Soldier',
      where: 'PlayerID = ? AND  Type = ?',
      whereArgs: [playerID, 1],
    );

    if (playerking.isNotEmpty) {
      final king = playerking[0];
      return Solider(
        soliderID: king['ID'],
        soliderType: SoliderType.king,
        soliderposition: king['Position'],
        playerID: playerID,
        // Track whether the king has moved (needed for castling eligibility).
        firstMove: king['FirstMove'] == 0 ? false : true,
        checker: king['Checker'] == 0 ? false : true,
      );
    }

    return null;
  }

  static Future<List<Solider>> _getPlayerIDQueen(int playerID) async {
    List<Map<String, dynamic>> playerQueen = await _database!.query(
      'Soldier',
      where: 'PlayerID = ? AND  Type = ?',
      whereArgs: [playerID, 2],
    );
    List<Solider> queens = [];

    if (playerQueen.isNotEmpty) {
      queens = playerQueen.map((queen) {
        return Solider(
          soliderID: queen['ID'],
          soliderType: SoliderType.queen,
          soliderposition: queen['Position'],
          playerID: playerID,
          firstMove: false,
          checker: queen['Checker'] == 0 ? false : true,
        );
      }).toList();
    }
    return queens;
  }

  static Future<bool> setSoldierAsChecker(int soldierID, int playerID) async {
    _database ??= await getInctence();
    int checked = await _database!.update(
      'Soldier',
      {'Checker': 1},
      where: 'ID = ? AND PlayerID = ?',
      whereArgs: [soldierID, playerID],
    );
    return checked > 0;
  }

  static Future<bool> unSetSoldierAsChecker(int soldierID, int playerID) async {
    _database ??= await getInctence();
    int unChecked = await _database!.update(
      'Soldier',
      {'Checker': 0},
      where: 'ID = ? AND PlayerID = ?',
      whereArgs: [soldierID, playerID],
    );
    return unChecked > 0;
  }

  static Future<void> deleteGame(int gameID) async {
    _database ??= await getInctence();
    await _database!.delete("Game", where: 'ID = ?', whereArgs: [gameID]);
  }

  static Future<void> _createGameTable(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Game (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    DateOfStart TEXT,
    timer TEXT,
    mode  INTEGER,
    winner INTEGER
    ) ''');
  }

  static Future<void> deleteMyDatabase() async {
    // 1. Close and drop any cached connection first, otherwise deleteDatabase
    //    cannot remove the file and later operations reuse a stale handle.
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // 2. Get the path to the database directory
    String databasesPath = await getDatabasesPath();

    // 3. Combine it with your database name
    String path = join(databasesPath, "chess.db");

    // 4. Delete the file
    await deleteDatabase(path);

    print("Database deleted successfully.");
  }

  static Future<void> _createPlayerTable(Database db, int version) async {
    await db.execute('''
  CREATE TABLE Player (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    GameID INTEGER,
    PlayerTitle TEXT,
    Color INTEGER,
    Turn INTEGER,
    Promotable INTEGER,
    RemainingTime INTEGER, 
    FOREIGN KEY (GameID) REFERENCES Game (ID) ON DELETE CASCADE
  )
''');
  }

  static Future<void> _createSoldierTable(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Soldier (
      ID INTEGER PRIMARY KEY AUTOINCREMENT,
      Type INTEGER,
      Position INTEGER,
      PlayerID INTEGER,
      FirstMove INTEGER,
      Checker INTEGER,
      FOREIGN KEY (PlayerID) REFERENCES Player (ID) ON DELETE CASCADE
    )
  ''');
  }

  static Future<int> addNewGame(Game game) async {
    int gameID = await _addNewGame(game);
    return gameID;
  }

  static Future<int> _addNewGame(Game game) async {
    _database ??= await getInctence();

    int gameID = await _database!.insert('Game', {
      'DateOfStart': DateTime.now().toIso8601String(),
      'winner': -1,
      'mode': game.mode, //1 for ai, 0 for normal.
      // Original time control in minutes (0 = open/no timer). Stored so a
      // rematch can reproduce the same time control.
      'timer': '${game.timeControlMinutes}',
    });
    await _addNewPlayer(game.playerOne, gameID);
    await _addNewPlayer(game.playerTwo, gameID);

    return gameID;
  }

  static Future<int> _addNewPlayer(Player player, int gameID) async {
    //_database ??= await getInctence();

    int playerID = await _database!.insert('Player', {
      'GameID': gameID, // Linking to the game we just created
      'PlayerTitle': player.playerTitle,
      'Color': player.color == ColorType.white ? 1 : 0, // Convert Color to int
      'Turn': player.turn ? 1 : 0, // Convert bool to int
      'Promotable': -1,
      'RemainingTime': player.remainingTime,
    });

    bool isWhite = (player.color == ColorType.white);
    // Must be awaited so every piece is committed before the game is reported
    // as created; otherwise these inserts race with the next DB operation and
    // pieces can be silently lost (broken rematch boards).
    await _addPlayerSoldiers(playerID, isWhite);

    return playerID;
  }

  static Future<void> _addPlayerSoldiers(int playerID, bool first) async {
    //king
    await _database!.insert('Soldier', {
      'Type': 1,
      'Position': first ? 3 : 59,
      'PlayerID': playerID,
      // King starts unmoved; needed for castling eligibility.
      'FirstMove': 1,
      'Checker': 0,
    });
    //queen
    await _database!.insert('Soldier', {
      'Type': 2,
      'Position': first ? 4 : 60,
      'PlayerID': playerID,
      'FirstMove': 0,
      'Checker': 0,
    });
    //pawn
    if (first) {
      for (int i = 0; i <= 7; i++) {
        await _database!.insert('Soldier', {
          'Type': 3,
          'Position': 8 + i,
          'PlayerID': playerID,
          'FirstMove': 1,
          'Checker': 0,
        });
      }
    } else {
      for (int i = 47; i < 48 + 7; i++) {
        await _database!.insert('Soldier', {
          'Type': 3,
          'Position': i + 1,
          'PlayerID': playerID,
          'FirstMove': 1,
          'Checker': 0,
        });
      }
    }

    //rocks
    await _database!.insert('Soldier', {
      'Type': 4,
      'Position': first ? 0 : 56,
      'PlayerID': playerID,
      // Rooks start unmoved; needed for castling eligibility.
      'FirstMove': 1,
      'Checker': 0,
    });
    await _database!.insert('Soldier', {
      'Type': 4,
      'Position': first ? 7 : 63,
      'PlayerID': playerID,
      // Rooks start unmoved; needed for castling eligibility.
      'FirstMove': 1,
      'Checker': 0,
    });

    //knights

    await _database!.insert('Soldier', {
      'Type': 5,
      'Position': first ? 1 : 57,
      'PlayerID': playerID,
      'FirstMove': 0,
      'Checker': 0,
    });

    await _database!.insert('Soldier', {
      'Type': 5,
      'Position': first ? 6 : 62,
      'PlayerID': playerID,
      'FirstMove': 0,
      'Checker': 0,
    });

    //bishops
    await _database!.insert('Soldier', {
      'Type': 6,
      'Position': first ? 2 : 58,
      'PlayerID': playerID,
      'FirstMove': 0,
      'Checker': 0,
    });

    await _database!.insert('Soldier', {
      'Type': 6,
      'Position': first ? 5 : 61,
      'PlayerID': playerID,
      'FirstMove': 0,
      'Checker': 0,
    });
  }
}
