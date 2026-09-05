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
  });
}