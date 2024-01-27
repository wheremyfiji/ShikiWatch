import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'enumerate_items.dart';
import 'network_event.dart';
import 'network_logger.dart';

/// Screen that displays log entries list.
class NetworkLoggerScreen extends StatelessWidget {
  NetworkLoggerScreen({Key? key, NetworkEventList? eventList})
      : eventList = eventList ?? NetworkLogger.instance,
        super(key: key);

  /// Event list to listen for event changes.
  final NetworkEventList eventList;

  /// Opens screen.
  static Future<void> open(
    BuildContext context, {
    NetworkEventList? eventList,
  }) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            NetworkLoggerScreen(eventList: eventList),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  final TextEditingController searchController =
      TextEditingController(text: null);

  /// filte events with search keyword
  List<NetworkEvent> getEvents() {
    if (searchController.text.isEmpty) return eventList.events;

    final query = searchController.text.toLowerCase();
    return eventList.events
        .where((it) => it.request?.uri.toLowerCase().contains(query) ?? false)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Logs'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => eventList.clear(),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: eventList.stream,
        builder: (context, snapshot) {
          // filter events with search keyword
          final events = getEvents();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (text) {
                    eventList.updated(NetworkEvent());
                  },
                  autocorrect: false,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    filled: true,
                    //fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    suffix: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: searchController,
                      builder: (context, value, child) => value.text.isNotEmpty
                          ? Text('${getEvents().length} results')
                          : const SizedBox(),
                    ),
                    hintText: "enter keyword to search",
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: enumerateItems<NetworkEvent>(
                    events,
                    (context, item) => ListTile(
                      key: ValueKey(item.request),
                      title: Text(
                        item.request!.method,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        item.request!.uri.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: Icon(
                        item.error == null
                            ? (item.response == null
                                ? Icons.hourglass_empty
                                : Icons.done)
                            : Icons.error,
                      ),
                      trailing: _AutoUpdate(
                        duration: const Duration(seconds: 1),
                        builder: (context) =>
                            Text(_timeDifference(item.timestamp!)),
                      ),
                      onTap: () => NetworkLoggerEventScreen.open(
                        context,
                        item,
                        eventList,
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

String _timeDifference(DateTime time, [DateTime? origin]) {
  origin ??= DateTime.now();
  var delta = origin.difference(time);
  if (delta.inSeconds < 90) {
    return '${delta.inSeconds} s';
  } else if (delta.inMinutes < 90) {
    return '${delta.inMinutes} m';
  } else {
    return '${delta.inHours} h';
  }
}

const _jsonEncoder = JsonEncoder.withIndent('  ');

/// Screen that displays log entry details.
class NetworkLoggerEventScreen extends StatelessWidget {
  const NetworkLoggerEventScreen({Key? key, required this.event})
      : super(key: key);

  static Route<void> route({
    required NetworkEvent event,
    required NetworkEventList eventList,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, _, __) => StreamBuilder(
        stream: eventList.stream.where((item) => item.event == event),
        builder: (context, snapshot) => NetworkLoggerEventScreen(event: event),
      ),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  /// Opens screen.
  static Future<void> open(
    BuildContext context,
    NetworkEvent event,
    NetworkEventList eventList,
  ) {
    return Navigator.of(context).push(route(
      event: event,
      eventList: eventList,
    ));
  }

  /// Which event to display details for.
  final NetworkEvent event;

  Widget buildBodyViewer(BuildContext context, dynamic body) {
    String text;
    if (body == null) {
      text = '';
    } else if (body is String) {
      text = body;
    } else if (body is List || body is Map) {
      text = _jsonEncoder.convert(body);
    } else {
      text = body.toString();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Copied to clipboard'),
            behavior: SnackBarBehavior.floating,
          ));
        },
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontFamilyFallback: ['sans-serif'],
          ),
        ),
      ),
    );
  }

  Widget buildHeadersViewer(
    BuildContext context,
    List<MapEntry<String, String>> headers,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: headers.map((e) => SelectableText(e.key)).toList(),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: headers.map((e) => SelectableText(e.value)).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildRequestView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 15),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
          child: Text('URL', style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                event.request!.method,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(width: 15),
              Expanded(child: SelectableText(event.request!.uri.toString())),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
          child:
              Text('TIMESTAMP', style: Theme.of(context).textTheme.bodySmall),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(event.timestamp.toString()),
        ),
        if (event.request!.headers.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
            child:
                Text('HEADERS', style: Theme.of(context).textTheme.bodySmall),
          ),
          buildHeadersViewer(context, event.request!.headers.entries),
        ],
        if (event.error != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
            child: Text('ERROR', style: Theme.of(context).textTheme.bodySmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              event.error.toString(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
          child: Text('BODY', style: Theme.of(context).textTheme.bodySmall),
        ),
        buildBodyViewer(context, event.request!.data),
      ],
    );
  }

  Widget buildResponseView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 15),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
          child: Text('RESULT', style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                event.response!.statusCode.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(width: 15),
              Expanded(child: Text(event.response!.statusMessage)),
            ],
          ),
        ),
        if (event.response?.headers.isNotEmpty ?? false) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
            child:
                Text('HEADERS', style: Theme.of(context).textTheme.bodySmall),
          ),
          buildHeadersViewer(
            context,
            event.response?.headers.entries ?? [],
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
          child: Text('BODY', style: Theme.of(context).textTheme.bodySmall),
        ),
        buildBodyViewer(context, event.response?.data),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showResponse = event.response != null;

    Widget? bottom;
    if (showResponse) {
      bottom = TabBar(
        tabs: const [
          Tab(text: 'Request'),
          Tab(text: 'Response'),
        ],
        indicatorWeight: 1.5,
        tabAlignment: TabAlignment.fill,
        splashBorderRadius: BorderRadius.circular(12.0),
      );
    }

    return DefaultTabController(
      initialIndex: 0,
      length: showResponse ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Log Entry'),
          bottom: (bottom as PreferredSizeWidget?),
        ),
        body: Builder(
          builder: (context) => TabBarView(
            children: <Widget>[
              buildRequestView(context),
              if (showResponse) buildResponseView(context),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget builder that re-builds widget repeatedly with [duration] interval.
class _AutoUpdate extends StatefulWidget {
  const _AutoUpdate({Key? key, required this.duration, required this.builder})
      : super(key: key);

  /// Re-build interval.
  final Duration duration;

  /// Widget builder to build widget.
  final WidgetBuilder builder;

  @override
  _AutoUpdateState createState() => _AutoUpdateState();
}

class _AutoUpdateState extends State<_AutoUpdate> {
  Timer? _timer;

  void _setTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.duration, (timer) {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(_AutoUpdate old) {
    if (old.duration != widget.duration) {
      _setTimer();
    }
    super.didUpdateWidget(old);
  }

  @override
  void initState() {
    _setTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
