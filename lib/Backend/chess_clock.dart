/// Pure per-player countdown clock shared by the board provider and its
/// tests. Kept free of Flutter/riverpod/DB dependencies so the timeout rules
/// can be unit tested in isolation.
class ChessClock {
  ChessClock({required this.playerOneTime, required this.playerTwoTime});

  /// Remaining time for each player, in seconds. `0` means "no clock"
  /// (legacy/unlimited games never run a timer).
  int playerOneTime;
  int playerTwoTime;

  /// Winner on timeout: 0 = playerOne (white), 1 = playerTwo (black),
  /// -1 = no timeout has happened yet.
  int _timeoutWinner = -1;

  int get timeoutWinner => _timeoutWinner;

  bool get hasTimedOut => _timeoutWinner != -1;

  bool get isRunning => !hasTimedOut && playerOneTime > 0 && playerTwoTime > 0;

  /// Advances the clock one second for the player whose turn it is. When that
  /// player runs out of time, the opponent is declared the winner and the
  /// returning value is that winner's index (0 or 1). Otherwise -1 is
  /// returned and ticking can continue.
  int tick(bool isPlayerOneTurn) {
    if (hasTimedOut) return _timeoutWinner;

    if (isPlayerOneTurn) {
      if (playerOneTime > 0) playerOneTime -= 1;
      if (playerOneTime <= 0) _timeoutWinner = 1;
    } else {
      if (playerTwoTime > 0) playerTwoTime -= 1;
      if (playerTwoTime <= 0) _timeoutWinner = 0;
    }
    return _timeoutWinner;
  }

  /// Formats a remaining time in seconds as "m:ss" (e.g. 9:05, 0:30, 10:00).
  /// A non-positive value renders as "0:00".
  static String formatTime(int seconds) {
    final int safe = seconds < 0 ? 0 : seconds;
    final String minutes = (safe ~/ 60).toString();
    final String secs = (safe % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  /// True when the clock is running low (a classic red "danger" warning).
  static bool isLowTime(int seconds) => seconds > 0 && seconds <= 30;
}