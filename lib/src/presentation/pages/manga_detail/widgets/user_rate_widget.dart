import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:shikidev/src/presentation/widgets/cool_chip.dart';

import '../../../../domain/models/manga_ranobe.dart';
import '../../../../domain/models/manga_short.dart';
import '../../../../services/secure_storage/secure_storage_service.dart';

class UserRateWidget extends StatelessWidget {
  final MangaShort manga;
  final MangaRanobe data;

  const UserRateWidget({
    super.key,
    required this.manga,
    required this.data,
  });

  String getRateStatus(String value) {
    String status;

    const map = {
      'planned': 'В планах',
      'watching': 'Читаю',
      'rewatching': 'Перечитываю',
      'completed': 'Прочитано',
      'on_hold': 'Отложено',
      'dropped': 'Брошено'
    };

    status = map[value] ?? '';

    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Отслеживание',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 8,
        ),
        SizedBox(
          width: double.infinity,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              //padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start, //end
                spacing: 8,
                runSpacing: 0,
                children: [
                  CoolChip(
                    label: 'Статус: ${getRateStatus(data.userRate!.status!)}',
                  ),
                  CoolChip(
                    label: 'Тома: ${data.userRate!.volumes.toString()}',
                  ),
                  CoolChip(
                    label: 'Главы: ${data.userRate!.chapters.toString()}',
                  ),
                  CoolChip(
                    label: 'Оценка: ${data.userRate!.score.toString()}',
                  ),
                  CoolChip(
                    label: 'Перечитано: ${data.userRate!.rewatches.toString()}',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      //mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Отслеживание',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 4,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: ExtendedNetworkImageProvider(
                SecureStorageService.instance.userProfileImage,
                cache: true,
              ),
              radius: 36,
            ),
            const SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.userRate == null) ...[
                  const Text('empty'),
                ] else ...[
                  Text(
                    'Статус: ${getRateStatus(data.userRate!.status!)}',
                    maxLines: 1,
                  ),
                  Text(
                    'Тома: ${data.userRate!.volumes.toString()}',
                    maxLines: 1,
                  ),
                  Text(
                    'Главы: ${data.userRate!.chapters.toString()}',
                    maxLines: 1,
                  ),
                  Text(
                    'Оценка: ${data.userRate!.score.toString()}',
                    maxLines: 1,
                  ),
                  Text(
                    'Перечитано: ${data.userRate!.rewatches.toString()}',
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: () {},
            child: const Text('Изменить'),
          ),
        ),
      ],
    );
  }
}
