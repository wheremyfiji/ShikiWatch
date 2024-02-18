import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/models/pages_extra.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/error_widget.dart';
import 'anilib_source_controller.dart';

class AnilibSourcePage extends ConsumerWidget {
  const AnilibSourcePage(this.extra, {super.key});

  final AnimeSourcePageExtra extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AnilibNotifierParameters(extra);

    final controller = ref.watch(anilibSourceProvider(p));
    final playlistAsync = controller.playlistAsync;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(anilibSourceProvider(p)),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: Text(
                  extra.animeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
              ),
              ...playlistAsync.when(
                data: (playlist) {
                  if (playlist.isEmpty) {
                    return [
                      const SliverFillRemaining(
                        child: Center(child: Text('playlist is empty')),
                      ),
                    ];
                  }

                  return [
                    SliverList.builder(
                      itemCount: playlist.length,
                      itemBuilder: (context, index) {
                        final item = playlist[index];
                        return ListTile(
                          onTap: () {},
                          title: Text('Серия ${item.number}'),
                          subtitle:
                              item.name.isNotEmpty ? Text(item.name) : null,
                        );
                      },
                    ),
                  ];
                },
                loading: () => [
                  const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator())),
                ],
                error: (err, stack) => [
                  SliverFillRemaining(
                    child: CustomErrorWidget(
                      err.toString(),
                      () => ref.invalidate(anilibSourceProvider(p)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
