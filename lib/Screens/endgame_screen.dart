import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class WinnerDialog extends StatelessWidget {
  final String winnerName;
  final bool isWhiteWinner;
  final VoidCallback onRematch;
  final VoidCallback onHome;
  final String resultLabel;

  const WinnerDialog({
    super.key,
    required this.winnerName,
    required this.isWhiteWinner,
    required this.onRematch,
    required this.onHome,
    this.resultLabel = "CHECKMATE",
  });

  @override
  Widget build(BuildContext context) {
    // Define the glow color based on victory (gold for a premium feel)
    final Color glowColor = Colors.amberAccent;
    final Color pieceColor = isWhiteWinner ? Colors.white : Colors.black;
    final String teamName = isWhiteWinner ? "White" : "Black";

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A), // Matches your app's background
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: glowColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Crown Icon with Glow ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: glowColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(MdiIcons.crown, color: glowColor, size: 64),
              ),
              const SizedBox(height: 24),

              // --- Subtitle (CHECKMATE / WON ON TIME) ---
              Text(
                resultLabel,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: 12),

              // --- Winner Name ---
              Text(
                winnerName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // --- Winning Piece & Color Indicator ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      MdiIcons.chessKing,
                      color: pieceColor,
                      size: 24,
                      shadows: isWhiteWinner
                          ? const [Shadow(color: Colors.white54, blurRadius: 4)]
                          : const [],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$teamName wins!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- Action Buttons ---
              Row(
                children: [
                  // Return to Home Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onHome,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.white24, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "HOME",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Rematch Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRematch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF2E7D32,
                        ), // Deep gaming green
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: Colors.greenAccent.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "REMATCH",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
