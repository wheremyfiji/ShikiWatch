import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';

class NextEpisodeCountdown extends StatefulWidget {
  const NextEpisodeCountdown({
    super.key,
    this.duration = 7,
    this.minWidth = 320.0,
    required this.number,
    required this.onCancel,
    required this.onPlay,
  });

  final int number;
  final int duration;
  final double minWidth;

  final VoidCallback onCancel;
  final VoidCallback onPlay;

  @override
  State<NextEpisodeCountdown> createState() => _NextEpisodeCountdownState();
}

class _NextEpisodeCountdownState extends State<NextEpisodeCountdown>
    with SingleTickerProviderStateMixin<NextEpisodeCountdown> {
  late double width;
  late final _controller = AnimationController(
    vsync: this,
    duration: Duration(seconds: widget.duration),
  )
    ..addListener(_update)
    ..addStatusListener(_statusListener)
    ..forward();

  late final _tween = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).animate(
    _controller,
  );

  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onPlay.call();
    }
  }

  void _update() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_update);
    _controller.removeStatusListener(_statusListener);
    _controller.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    width = MediaQuery.sizeOf(context).width / 3;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width < widget.minWidth ? widget.minWidth : width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            //'Следующая серия',
            '${widget.number} СЕРИЯ',
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          RichText(
            text: TextSpan(
              text: 'начнется через ',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
                letterSpacing: 1.2,
              ),
              children: [
                TextSpan(
                  text: '${(_tween.value * widget.duration).ceil()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          LinearProgressIndicator(
            value: _tween.value,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(
            height: 12.0,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.tonal(
                onPressed: widget.onCancel,
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                child: const Text('Отмена'),
              ),
              const SizedBox(
                width: 8.0,
              ),
              Expanded(
                child: FilledButton(
                  onPressed: widget.onPlay,
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  child: const Text('Воспроизвести'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
