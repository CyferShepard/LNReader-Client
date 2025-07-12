import 'package:flutter/material.dart';

class WebsocketToast extends StatefulWidget {
  final ValueNotifier<String> messageNotifier;
  final Duration duration;
  final String keyId;

  const WebsocketToast({
    super.key,
    required this.messageNotifier,
    required this.keyId,
    this.duration = const Duration(seconds: 5),
  });

  static final Map<String, OverlayEntry> _activeToasts = {};
  static final Map<String, ValueNotifier<String>> _notifiers = {};
  static final List<String> _toastOrder = [];
  static BuildContext? _lastContext;

  static void show(
    BuildContext context,
    String message, {
    String key = 'websocket',
    Duration duration = const Duration(seconds: 5),
  }) {
    final overlay = Overlay.of(context);
    _lastContext = context;

    // If toast exists, update message and reset timer
    if (_activeToasts.containsKey(key)) {
      _notifiers[key]?.value = message;
      _resetToastTimer(key, duration);
      return;
    }

    // If max toasts reached, remove the oldest
    if (_toastOrder.length >= 5) {
      final oldestKey = _toastOrder.removeAt(0);
      _activeToasts[oldestKey]?.remove();
      _activeToasts.remove(oldestKey);
      _notifiers.remove(oldestKey);
    }

    final notifier = ValueNotifier<String>(message);
    _notifiers[key] = notifier;

    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastStack(
        toasts: _toastOrder
            .map((k) => WebsocketToast(
                  messageNotifier: _notifiers[k]!,
                  keyId: k,
                  duration: duration,
                ))
            .toList()
          ..add(WebsocketToast(
            messageNotifier: notifier,
            keyId: key,
            duration: duration,
          )),
      ),
    );

    _activeToasts[key] = overlayEntry;
    _toastOrder.add(key);
    overlay.insert(overlayEntry);

    _resetToastTimer(key, duration);
  }

  static void _resetToastTimer(String key, Duration duration) {
    Future.delayed(duration, () {
      if (_activeToasts.containsKey(key)) {
        _activeToasts[key]?.remove();
        _activeToasts.remove(key);
        _notifiers.remove(key);
        _toastOrder.remove(key);

        // Rebuild the overlay stack if there are remaining toasts
        if (_toastOrder.isNotEmpty && _lastContext != null) {
          final overlay = Overlay.of(_lastContext!);
          // Remove all current overlay entries
          for (var entry in _activeToasts.values) {
            entry.remove();
          }
          _activeToasts.clear();

          // Re-insert remaining toasts
          final overlayEntry = OverlayEntry(
            builder: (context) => _ToastStack(
              toasts: _toastOrder
                  .map((k) => WebsocketToast(
                        messageNotifier: _notifiers[k]!,
                        keyId: k,
                        duration: duration,
                      ))
                  .toList(),
            ),
          );
          for (var k in _toastOrder) {
            _activeToasts[k] = overlayEntry;
          }
          overlay.insert(overlayEntry);
        }
      }
    });
  }

  @override
  State<WebsocketToast> createState() => _WebsocketToast();
}

class _WebsocketToast extends State<WebsocketToast> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.messageNotifier,
      builder: (context, value, _) => Positioned(
        bottom: 32 + 60.0 * WebsocketToast._toastOrder.indexOf(widget.keyId),
        right: 32,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastStack extends StatelessWidget {
  final List<WebsocketToast> toasts;
  const _ToastStack({required this.toasts});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: toasts,
    );
  }
}
