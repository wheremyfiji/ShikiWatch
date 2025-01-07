import 'package:flutter/material.dart';

import '../../../constants/config.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../widgets/cached_image.dart';

// class ContinueDialog extends StatelessWidget {
//   const ContinueDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Продолжить просмотр?'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context, ContinueDialogResult.start),
//           child: const Text("Нет"),
//         ),
//         FilledButton(
//           onPressed: () => Navigator.pop(context, ContinueDialogResult.saved),
//           child: const Text("Да"),
//         ),
//       ],
//     );
//   }
// }

class ContinueDialogNew extends StatelessWidget {
  const ContinueDialogNew({
    super.key,
    required this.titleName,
    required this.selectedEp,
    required this.savedPosition,
    required this.imageUrl,
    required this.studioName,
  });

  final String titleName;
  final int selectedEp;
  final String savedPosition;
  final String imageUrl;
  final String studioName;

  @override
  Widget build(BuildContext context) {
    final t = _parseDuration(savedPosition);

    String formattedPosition = t.inHours > 0
        ? "${(t.inHours).toString().padLeft(2, '0')}:${(t.inMinutes % 60).toString().padLeft(2, '0')}:${(t.inSeconds % 60).toString().padLeft(2, '0')}"
        : "${(t.inMinutes).toString().padLeft(2, '0')}:${(t.inSeconds % 60).toString().padLeft(2, '0')}";

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: ListTile(
            leading: SizedBox(
              width: 48,
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedImage(
                    '${AppConfig.staticUrl}$imageUrl',
                  ),
                ),
              ),
            ),
            title: Text(
              titleName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '$studioName • Серия $selectedEp',
              style: TextStyle(
                fontSize: 12,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),
        ListTile(
          onTap: () => Navigator.pop(context, ContinueDialogResult.saved),
          leading: const Icon(Icons.play_circle_outline_rounded),
          title: RichText(
            text: TextSpan(
              text: 'Продолжить с ',
              style: context.textTheme.bodyLarge,
              children: [
                TextSpan(
                  text: formattedPosition,
                  style: TextStyle(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          onTap: () => Navigator.pop(context, ContinueDialogResult.start),
          leading: const Icon(Icons.replay_rounded),
          title: const Text('Запустить сначала'),
        ),
        const SizedBox(
          height: 8.0,
        ),
      ],
    );
  }

  Duration _parseDuration(String timeString) {
    List<String> parts = timeString.split(':');
    if (parts.length != 3) {
      throw const FormatException('Invalid time string format');
    }

    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    double seconds = double.parse(parts[2]);

    return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds.toInt(),
        milliseconds: (seconds * 1000).toInt() % 1000);
  }

  static Future<ContinueDialogResult?> show(
    BuildContext context, {
    required String titleName,
    required int selectedEp,
    required String savedPosition,
    required String imageUrl,
    required String studioName,
  }) async {
    return await showModalBottomSheet<ContinueDialogResult>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: context.mediaQuery.size.width >= 700 ? 700 : double.infinity,
      ),
      builder: (_) => SafeArea(
        child: ContinueDialogNew(
          titleName: titleName,
          selectedEp: selectedEp,
          savedPosition: savedPosition,
          imageUrl: imageUrl,
          studioName: studioName,
        ),
      ),
    );
  }
}

enum ContinueDialogResult {
  cancel,
  start,
  saved,
}
