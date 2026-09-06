import 'package:flutter_test/flutter_test.dart';

import 'package:chess_app_v1/Backend/chess_clock.dart';

void main() {
  test('tick decrements only the active player by one second', () {
    final ChessClock clock = ChessClock(
      playerOneTime: 600,
      playerTwoTime: 600,
    );

    expect(clock.tick(true), -1);
    expect(clock.playerOneTime, 599);
    expect(clock.playerTwoTime, 600);

    expect(clock.tick(false), -1);
    expect(clock.playerOneTime, 599);
    expect(clock.playerTwoTime, 599);
  });

  test('player one timing out makes player two the winner', () {
    final ChessClock clock = ChessClock(playerOneTime: 2, playerTwoTime: 30);

    expect(clock.tick(true), -1);
    expect(clock.isRunning, true);

    expect(clock.tick(true), 1);
    expect(clock.timeoutWinner, 1);
    expect(clock.hasTimedOut, true);
    expect(clock.isRunning, false);

    // Once flagged, further ticks are inert.
    expect(clock.tick(false), 1);
    expect(clock.playerTwoTime, 30);
  });

  test('player two timing out makes player one the winner', () {
    final ChessClock clock = ChessClock(playerOneTime: 30, playerTwoTime: 1);

    expect(clock.tick(false), 0);
    expect(clock.timeoutWinner, 0);
    expect(clock.playerOneTime, 30);
  });

  test('a clock never drops below zero', () {
    final ChessClock clock = ChessClock(playerOneTime: 0, playerTwoTime: 10);

    // Ticking an already-exhausted player still flags the timeout at zero.
    expect(clock.tick(true), 1);
    expect(clock.playerOneTime, 0);
  });

  group('formatTime', () {
    test('renders mm:ss with zero padding', () {
      expect(ChessClock.formatTime(0), '0:00');
      expect(ChessClock.formatTime(5), '0:05');
      expect(ChessClock.formatTime(65), '1:05');
      expect(ChessClock.formatTime(600), '10:00');
      expect(ChessClock.formatTime(9 * 60 + 59), '9:59');
    });

    test('clamps negative values to 0:00', () {
      expect(ChessClock.formatTime(-3), '0:00');
    });
  });

  group('isLowTime', () {
    test('flags 1..30 seconds as low', () {
      expect(ChessClock.isLowTime(1), true);
      expect(ChessClock.isLowTime(30), true);
      expect(ChessClock.isLowTime(31), false);
      expect(ChessClock.isLowTime(0), false);
      expect(ChessClock.isLowTime(-5), false);
    });
  });
}