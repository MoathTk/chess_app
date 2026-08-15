import 'package:flutter/material.dart';
import 'package:chess_app_v1/Validations/inputs_validations.dart';
import 'package:chess_app_v1/Models/Game.dart';
import 'package:chess_app_v1/Screens/loading_screen.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final TextEditingController p1Controller = TextEditingController();
  final TextEditingController p2Controller = TextEditingController();

  int selectedTime = 10;
  bool isGoingToPlay = false;

  // NEW STATE: track the game mode
  bool isVsComputer = false;

  void showNotAddedGameBanner(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: Container(
          padding: const EdgeInsets.all(16),
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFC72C41),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.gpp_bad_rounded, color: Colors.white, size: 40),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Game Not Saved",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Check player names to continue.",
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgCol = Color(0xFF1A1A1A);
    const Color accentCol = Colors.orangeAccent;
    const Color cardCol = Color(0xFF2C2C2C);

    return isGoingToPlay == false
        ? Scaffold(
            backgroundColor: bgCol,
            appBar: AppBar(
              title: const Text(
                "Create Match",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. MODE SELECTOR (1v1 vs Computer)
                  _buildModeSelector(accentCol, cardCol),

                  const SizedBox(height: 30),

                  // 2. PLAYER INPUTS
                  _buildPlayerInput(
                    p1Controller,
                    "Player 1 (White)",
                    Icons.person,
                    accentCol,
                    true, // Always enabled
                  ),
                  const SizedBox(height: 20),
                  _buildPlayerInput(
                    p2Controller,
                    isVsComputer ? "AI Difficulty: Easy" : "Player 2 (Black)",
                    isVsComputer ? Icons.computer : Icons.person_outline,
                    isVsComputer ? Colors.greenAccent : Colors.blueAccent,
                    !isVsComputer, // Disable if playing computer
                  ),

                  const SizedBox(height: 40),

                  // 3. TIME CONTROL
                  const Text(
                    "TIME CONTROL",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTimeOption(5, "Blitz", selectedTime == 5),
                        const SizedBox(width: 10),
                        _buildTimeOption(10, "Rapid", selectedTime == 10),
                        const SizedBox(width: 10),
                        _buildTimeOption(30, "Classic", selectedTime == 30),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // 4. START BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // If computer, force a name for P2
                        if (isVsComputer) p2Controller.text = "Computer (AI)";

                        if (InputsValidations.checkInputs(
                          p1Controller.text,
                          p2Controller.text,
                        )) {
                          Game.addNewGame(
                            p1Controller.text,
                            p2Controller.text,
                            isVsComputer,
                            selectedTime,
                            selectedTime,
                          );
                          setState(() => isGoingToPlay = true);
                        } else {
                          showNotAddedGameBanner(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentCol,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "START GAME",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : const LoadingMatchScreen();
  }

  // NEW: Mode Selector UI
  Widget _buildModeSelector(Color accent, Color card) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(child: _modeButton("1 vs 1", !isVsComputer, accent)),
          Expanded(child: _modeButton("vs Computer", isVsComputer, accent)),
        ],
      ),
    );
  }

  Widget _modeButton(String title, bool isActive, Color accent) {
    return GestureDetector(
      onTap: () => setState(() {
        isVsComputer = title.contains("Computer");
        if (isVsComputer) p2Controller.clear();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInput(
    TextEditingController controller,
    String label,
    IconData icon,
    Color color,
    bool enabled,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFF252525) : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: enabled ? null : Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: enabled ? color : Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeOption(int time, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedTime = time),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              "${time}m",
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black54 : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
