class ApiRateLimiter {
  static const maxCallsPerMinute = 8;
  static const window = Duration(minutes: 1);

  final _callTimes = <DateTime>[];
  Future<void> _lastInQueue = Future.value();
  var _waitingCalls = 0;

  bool get canCallNow {
    _forgetOldCalls();
    return _waitingCalls == 0 && _callTimes.length < maxCallsPerMinute;
  }

  Future<T> schedule<T>(Future<T> Function() call) {
    _waitingCalls++;
    final result = _lastInQueue.then((_) async {
      await _waitForFreeSlot();
      _waitingCalls--;
      _callTimes.add(DateTime.now());
      return call();
    });
    _lastInQueue = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  void markQuotaReached() {
    final now = DateTime.now();
    _callTimes
      ..clear()
      ..addAll(List.filled(maxCallsPerMinute, now));
  }

  Future<void> _waitForFreeSlot() async {
    _forgetOldCalls();
    while (_callTimes.length >= maxCallsPerMinute) {
      final freeAt = _callTimes.first.add(window);
      await Future<void>.delayed(freeAt.difference(DateTime.now()));
      _forgetOldCalls();
    }
  }

  void _forgetOldCalls() {
    final windowStart = DateTime.now().subtract(window);
    _callTimes.removeWhere((time) => !time.isAfter(windowStart));
  }
}
