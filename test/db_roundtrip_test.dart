import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:chess_app_v1/Models/Game.dart';
import 'package:chess_app_v1/DataBase/chess_db.dart';

// Regression test: a freshly created game (like a rematch) must keep all 32
// pieces when persisted and reloaded. Previously the pieces were inserted
// without awaiting, so some inserts raced the next DB read and were lost.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('rematch game round-trip keeps all 32 pieces', () async {
    await ChessDb.deleteMyDatabase();

    int gameID = await Game.addNewGame('White', 'Black', false, 10, 10);
    List<Game> games = await ChessDb.getAllUserGames();

    Game game = games.firstWhere((g) => g.gameID == gameID);
    expect(game.playerOne.getAllSoldiers().length, 16);
    expect(game.playerTwo.getAllSoldiers().length, 16);
    expect(game.playerOne.king.soliderposition, 3);
    expect(game.playerTwo.king.soliderposition, 59);
    expect(game.timeControlMinutes, 10);
  });

  test('open game (no timer) round-trips and creates no clock', () async {
    await ChessDb.deleteMyDatabase();

    int gameID = await Game.addNewGame('White', 'Black', false, 0, 0);
    List<Game> games = await ChessDb.getAllUserGames();

    Game game = games.firstWhere((g) => g.gameID == gameID);
    expect(game.timeControlMinutes, 0);
    expect(game.playerOne.remainingTime, 0);
    expect(game.playerTwo.remainingTime, 0);
  });

  test('time control persists in seconds and reloads', () async {
    await ChessDb.deleteMyDatabase();

    // 10 minutes per side, stored as seconds on creation.
    int gameID = await Game.addNewGame('White', 'Black', false, 10, 10);
    List<Game> firstLoad = await ChessDb.getAllUserGames();
    Game fresh = firstLoad.firstWhere((g) => g.gameID == gameID);
    expect(fresh.playerOne.remainingTime, 600);
    expect(fresh.playerTwo.remainingTime, 600);

    // Keeping only the white player using 125s must survive a reload.
    await ChessDb.updateRemainingTime(fresh.playerOne.id, 475);
    List<Game> secondLoad = await ChessDb.getAllUserGames();
    Game resumed = secondLoad.firstWhere((g) => g.gameID == gameID);
    expect(resumed.playerOne.remainingTime, 475);
    expect(resumed.playerTwo.remainingTime, 600);

    // A zeroed loser stays zero after reload.
    await ChessDb.updateRemainingTime(resumed.playerTwo.id, 0);
    List<Game> thirdLoad = await ChessDb.getAllUserGames();
    Game finished = thirdLoad.firstWhere((g) => g.gameID == gameID);
    expect(finished.playerTwo.remainingTime, 0);
  });
}
