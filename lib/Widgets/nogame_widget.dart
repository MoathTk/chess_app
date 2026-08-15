import 'package:flutter/material.dart';

class NogameWidget extends StatelessWidget {
  const NogameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.grey[100], // Soft background color
            borderRadius: BorderRadius.circular(20), // Rounded corners
            border: Border.all(
              color: Colors.grey[300]!,
              width: 2,
            ), // Subtle border
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Shrinks to fit content
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Large Icon
              Icon(
                Icons.offline_bolt, // Or Icons.videogame_asset_off
                size: 80,
                color: Colors.blue[600],
              ),
              const SizedBox(height: 16),

              // 2. Headline Text
              Text(
                "No Games Found",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),

              // 3. Subtitle / Call to Action
              Text(
                "You haven't played any matches yet.\nTap the + button to start!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5, // Better line spacing
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
