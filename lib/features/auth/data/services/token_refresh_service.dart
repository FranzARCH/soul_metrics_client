import 'dart:async';

class TokenRefreshService {
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  void start({
    required Future<bool> Function() refreshAction,
    Duration interval = const Duration(minutes: 10),
  }) {
    stop();

    _refreshTimer = Timer.periodic(interval, (_) async {
      if (_isRefreshing) return;

      _isRefreshing = true;
      try {
        final ok = await refreshAction();
        if (!ok) {
          stop();
        }
      } finally {
        _isRefreshing = false;
      }
    });
  }

  void stop() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}
