class Date {
  static String convertToReadableTime(DateTime date) {
    return date.year.toString() +
        "-" +
        date.month.toString() +
        "-" +
        date.day.toString();
  }
}
