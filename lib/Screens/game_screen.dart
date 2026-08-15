import 'package:flutter/material.dart';
import 'package:chess_app_v1/Widgets/game_widget.dart';
import 'package:chess_app_v1/Widgets/nogame_widget.dart';
import 'package:chess_app_v1/Models/Game.dart';
import 'package:chess_app_v1/DataBase/chess_db.dart';
import 'package:chess_app_v1/Screens/add_new_game_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

List<Game> games = [];

class _GamesScreenState extends State<GamesScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadUserGames();
    // ChessDb.deleteMyDatabase();
    // setState(() {
    //   _isLoading = false;
    // });
  }

  Future<void> _loadUserGames() async {
    games = await ChessDb.getAllUserGames();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _goToNewGameScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewGameScreen()),
    );

    _loadUserGames();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      width: 400,
      height: double.infinity,
      child: games.isNotEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),

                        duration: Duration(
                          milliseconds: 400 + (index.clamp(0, 10) * 100),
                        ),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Dismissible(
                          key: Key(game.gameID.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.redAccent,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) async {
                            setState(() {
                              games.removeAt(index);
                            });
                            await ChessDb.deleteGame(game.gameID);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Game history deleted"),
                                ),
                              );
                            }
                          },
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Game?"),
                                content: const Text(
                                  "This will permanently remove this match record.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("CANCEL"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      "DELETE",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: GameWidget(game: game),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  onPressed: _goToNewGameScreen,
                  icon: const Icon(Icons.add),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const NogameWidget(),
                IconButton(
                  onPressed: _goToNewGameScreen,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
    );
  }
}
