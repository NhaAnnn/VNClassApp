class Getmonthnow {
  static int getCurrentMonth() {
    DateTime now = DateTime.now();
    return now.month; // Trả về số tháng (1-12)
  }

  static String getMonthName(int month) {
    const List<String> monthNames = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ];
    return monthNames[month - 1];
  }

  static String getMonthKey(int month) {
    const List<String> monthNames = [
      'month1',
      'month2',
      'month3',
      'month4',
      'month5',
      'month9',
      'month10',
      'month11',
      'month12'
    ];
    return monthNames[month - 1];
  }

  static int getMonthNumber(String monthName) {
    const List<String> monthNames = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ];

    int index = monthNames.indexOf(monthName);

    return index + 1;
  }

  static String currentMonth() {
    int currentMonth = getCurrentMonth();
    String monthName = getMonthName(currentMonth);
    return monthName;
  }

  static String currentMonthKey() {
    int currentMonth = getCurrentMonth();
    String monthKey = getMonthKey(currentMonth);
    return monthKey;
  }
}
