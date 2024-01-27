import 'dart:async';

import 'network_event.dart';

/// List that contains network events and notifies dependents on updates.
class NetworkEventList {
  final _controller = StreamController<UpdateEvent>.broadcast();

  /// Logged network events
  final events = <NetworkEvent>[];

  /// A source of asynchronous network events.
  Stream<UpdateEvent> get stream => _controller.stream;

  /// Notify dependents that [event] is updated.
  void updated(NetworkEvent event) {
    _controller.add(UpdateEvent(event));
  }

  /// Add [event] to [events] list and notify dependents.
  void add(NetworkEvent event) {
    events.insert(0, event);
    _controller.add(UpdateEvent(event));
  }

  /// Clear [events] and notify dependents.
  void clear() {
    events.clear();
    _controller.add(const UpdateEvent.clear());
  }

  /// Dispose resources.
  void dispose() {
    _controller.close();
  }
}

/// Event notified by [NetworkEventList.stream].
class UpdateEvent {
  const UpdateEvent(this.event);
  const UpdateEvent.clear() : event = null;

  final NetworkEvent? event;
}

/// Network logger interface.
class NetworkLogger extends NetworkEventList {
  static final NetworkLogger instance = NetworkLogger();
}
