import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher_string.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/extensions/buildcontext.dart';

class ShareBottomSheet extends StatelessWidget {
  const ShareBottomSheet({
    super.key,
    this.header,
    required this.url,
  });

  final Widget? header;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) ...[
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: header,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
        ],
        ListTile(
          onTap: () {
            launchUrlString(
              url,
              mode: LaunchMode.externalApplication,
            ).then(
              (_) => Navigator.of(context).pop(),
            );
          },
          leading: const Icon(Icons.open_in_browser_rounded),
          title: const Text('Открыть в браузере'),
        ),
        ListTile(
          onTap: () {
            Clipboard.setData(
              ClipboardData(
                text: url,
              ),
            ).then(
              (_) => Navigator.of(context).pop(),
            );
          },
          leading: const Icon(Icons.copy_rounded),
          title: const Text('Скопировать ссылку'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),
        ListTile(
          onTap: () {
            Share.share(url).then(
              (_) => Navigator.of(context).pop(),
            );
          },
          leading: const Icon(Icons.more_horiz_rounded),
          title: const Text('Ещё'),
        ),
        const SizedBox(
          height: 8.0,
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    required Widget header,
    required String url,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: context.mediaQuery.size.width >= 700 ? 700 : double.infinity,
      ),
      builder: (_) => SafeArea(
        child: ShareBottomSheet(
          header: header,
          url: url,
        ),
      ),
    );
  }
}
