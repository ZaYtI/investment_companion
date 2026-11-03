String dayKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String todayKey() => dayKey(DateTime.now());

String yesterdayKey() {
  final now = DateTime.now();
  return dayKey(DateTime(now.year, now.month, now.day - 1));
}
