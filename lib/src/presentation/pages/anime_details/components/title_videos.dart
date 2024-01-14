import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher_string.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../utils/extensions/string_ext.dart';
import '../../../widgets/cached_image.dart';
import '../../../../domain/models/anime.dart';
import '../videos_page.dart';

class TitleVideosWidget extends StatelessWidget {
  final Anime data;

  const TitleVideosWidget(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
            bottom: 4.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Видео',
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        AnimeVideosPage(
                      id: data.id ?? 0,
                      name: data.russian ?? data.name ?? '',
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
                icon: const Icon(
                  Icons.chevron_right_rounded,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(0),
            itemCount: data.videos!.length,
            itemBuilder: (context, index) {
              final isFirstItem = index == 0;
              final model = data.videos![index];

              String desc = model.name ?? '';

              if (desc.isEmpty) {
                desc = model.kind ?? '';
              }

              if (model.hosting != null && model.hosting!.isNotEmpty) {
                desc = '${model.hosting.capitalizeFirst} • $desc';
              }

              return Container(
                height: 180,
                margin: EdgeInsets.fromLTRB(isFirstItem ? 16 : 0, 0, 16, 0),
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: (16 / 9),
                      child: CachedImage(
                        model.imageUrl ?? '',
                      ),
                    ),
                    Positioned(
                      left: -1,
                      right: -1,
                      top: 40,
                      bottom: -1,
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        padding: const EdgeInsets.all(6.0),
                        alignment: Alignment.bottomCenter,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.transparent,
                              Colors.black54,
                              Colors.black87,
                            ],
                          ),
                        ),
                        child: Text(
                          desc,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      child: SizedBox(
                        height: 180,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () => launchUrlString(
                                model.url ?? '',
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
