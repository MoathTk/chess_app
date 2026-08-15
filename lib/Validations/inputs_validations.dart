class InputsValidations {
  static bool checkInputs(String PlayerOneName, String PlayerTwoName) {
    if (_ckeckPlayerNameText(PlayerOneName) &&
        _ckeckPlayerNameText(PlayerTwoName)) {
      return true;
    }
    return false;
  }

  static bool _ckeckPlayerNameText(String playerName) {
    return playerName.length >= 2;
  }
}
