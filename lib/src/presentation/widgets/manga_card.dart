//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../constants/config.dart';
import '../../domain/models/user_anime_rates.dart';
import '../../utils/shiki_utils.dart';
import '../../utils/target_platform.dart';
import '../widgets/image_with_shimmer.dart';

class MangaCardWidget extends StatelessWidget {
  final UserAnimeRates data;

  const MangaCardWidget(
    this.data, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createDT = DateTime.parse(data.createdAt!).toLocal();
    final updateDT = DateTime.parse(data.updatedAt!).toLocal();
    final createString = DateFormat('yyyy-MM-dd в HH:mm').format(createDT);
    final updateString = DateFormat('yyyy-MM-dd в HH:mm').format(updateDT);
    return Material(
      surfaceTintColor: Colors.transparent,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.transparent,
      child: Tooltip(
        waitDuration: TargetP.instance.isDesktop
            ? const Duration(seconds: 1)
            : const Duration(milliseconds: 0),
        message: 'Изменено: $updateString\nСоздано: $createString',
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            context.goNamed(
              'library_manga',
              params: <String, String>{
                'id': (data.manga?.id!).toString(),
              },
              extra: data.manga,
            );
          },
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ImageWithShimmerWidget(
                  imageUrl:
                      AppConfig.staticUrl + (data.manga?.image?.original ?? ''),
                  width: 120,
                  height: 150,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      (data.manga?.russian == ''
                              ? data.manga?.name
                              : data.manga?.russian) ??
                          '',
                      //data.manga?.russian ?? data.manga?.name ?? '',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getKind(data.manga?.kind ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
