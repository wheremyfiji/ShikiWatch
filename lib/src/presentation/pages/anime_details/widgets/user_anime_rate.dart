import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shikidev/src/utils/utils.dart';

import '../../../../data/data_sources/anime_data_src.dart';
import '../../../../data/data_sources/user_data_src.dart';
import '../../../../data/repositories/anime_repo.dart';
import '../../../../domain/models/anime.dart';
import '../../../../domain/models/animes.dart';
import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../../providers/anime_details_provider.dart';
import '../../../providers/library_tab_page_provider.dart';
import '../../../widgets/material_you_chip.dart';

class UserAnimeRateWidget extends HookConsumerWidget {
  final Animes anime;
  final Anime data;
  final String imageUrl;
  const UserAnimeRateWidget(this.anime, this.data, this.imageUrl, {super.key});

  String getRateStatus(String value) {
    String status;

    const map = {
      'planned': 'В планах',
      'watching': 'Смотрю',
      'rewatching': 'Пересматриваю',
      'completed': 'Просмотрено',
      'on_hold': 'Отложено',
      'dropped': 'Брошено'
    };

    status = map[value] ?? '';

    return status;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    Future<void> incRate() async {
      final rate = await ref.read(userDataSourceProvider).incrementUserRate(
          token: SecureStorageService.instance.token,
          rateId: data.userRate!.id!);

      if (rate.status != data.userRate!.status) {
        switch (data.userRate!.status) {
          case 'watching':
            {
              ref.read(watchingTabPageProvider).deleteAnime(data.id!);
            }
            break;
          case 'planned':
            {
              ref.read(plannedTabPageProvider).deleteAnime(data.id!);
              break;
            }
          case 'completed':
            {
              ref.read(completedTabPageProvider).deleteAnime(data.id!);
            }
            break;
          case 'rewatching':
            {
              ref.read(rewatchingTabPageProvider).deleteAnime(data.id!);
            }
            break;
          case 'on_hold':
            {
              ref.read(onHoldTabPageProvider).deleteAnime(data.id!);
            }
            break;
          case 'dropped':
            {
              ref.read(droppedTabPageProvider).deleteAnime(data.id!);
            }
            break;
          default:
        }
        switch (rate.status) {
          case 'watching':
            {
              ref.read(watchingTabPageProvider).addAnime(
                    animeId: data.id!,
                    anime: anime,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    episodes: rate.episodes,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          case 'planned':
            {
              ref.read(plannedTabPageProvider).addAnime(
                    animeId: data.id!,
                    anime: anime,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    episodes: rate.episodes,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
              break;
            }
          case 'completed':
            {
              ref.read(completedTabPageProvider).addAnime(
                    animeId: data.id!,
                    anime: anime,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    episodes: rate.episodes,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          case 'rewatching':
            {
              ref.read(rewatchingTabPageProvider).addAnime(
                    animeId: data.id!,
                    anime: anime,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    episodes: rate.episodes,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          case 'on_hold':
            {
              ref.read(onHoldTabPageProvider).addAnime(
                    animeId: data.id!,
                    anime: anime,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    episodes: rate.episodes,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          case 'dropped':
            {
              ref.read(droppedTabPageProvider).addAnime(
                    animeId: data.id!,
                    anime: anime,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    episodes: rate.episodes,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          default:
        }
        ref.read(titleInfoPageProvider(data.id!)).addRate(
              rateId: rate.id!,
              updatedAt: rate.updatedAt!,
              status: rate.status!,
              score: rate.score,
              episodes: rate.episodes,
              rewatches: rate.rewatches,
              text: rate.text,
              textHtml: rate.textHtml,
              createdAt: rate.createdAt,
            );
        return;
      }
      //switch (selectedStatus ?? initStatus) {
      switch (rate.status) {
        case 'watching':
          ref.read(watchingTabPageProvider).updateAnime(
                animeId: data.id!,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                episodes: rate.episodes,
                rewatches: rate.rewatches,
              );
          break;
        case 'planned':
          ref.read(plannedTabPageProvider).updateAnime(
                animeId: data.id!,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                episodes: rate.episodes,
                rewatches: rate.rewatches,
              );
          break;
        case 'completed':
          ref.read(completedTabPageProvider).updateAnime(
                animeId: data.id!,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                episodes: rate.episodes,
                rewatches: rate.rewatches,
              );
          break;
        case 'rewatching':
          ref.read(rewatchingTabPageProvider).updateAnime(
                animeId: data.id!,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                episodes: rate.episodes,
                rewatches: rate.rewatches,
              );
          break;
        case 'on_hold':
          ref.read(onHoldTabPageProvider).updateAnime(
                animeId: data.id!,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                episodes: rate.episodes,
                rewatches: rate.rewatches,
              );
          break;
        case 'dropped':
          ref.read(droppedTabPageProvider).updateAnime(
                animeId: data.id!,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                episodes: rate.episodes,
                rewatches: rate.rewatches,
              );
          break;
        default:
      }
      ref.read(titleInfoPageProvider(data.id!)).addRate(
            rateId: rate.id!,
            updatedAt: rate.updatedAt!,
            status: rate.status!,
            score: rate.score,
            episodes: rate.episodes,
            rewatches: rate.rewatches,
            text: rate.text,
            textHtml: rate.textHtml,
            createdAt: rate.createdAt,
          );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Отслеживание',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                //fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(
          height: 4,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              foregroundColor: Colors.transparent,
              //backgroundImage: CachedNetworkImageProvider(imageUrl),
              foregroundImage:
                  ExtendedNetworkImageProvider(imageUrl, cache: true),
              radius: 36,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text('Статус: ${myRate!.status}'),
                data.userRate == null
                    ? const Text(
                        'Статус: Не смотрю',
                        maxLines: 1,
                      )
                    : Text(
                        'Статус: ${getRateStatus(data.userRate!.status!)}',
                        maxLines: 1,
                      ),
                data.userRate == null
                    ? const Text(
                        'Эпизоды: -',
                        maxLines: 1,
                      )
                    : Text(
                        'Эпизоды: ${data.userRate!.episodes.toString()}',
                        maxLines: 1,
                      ),
                data.userRate == null
                    ? const Text(
                        'Оценка: -',
                        maxLines: 1,
                      )
                    : Text(
                        'Оценка: ${data.userRate!.score.toString()}',
                        maxLines: 1,
                      ),
                data.userRate == null
                    ? const Text(
                        'Пересмотрено: -',
                        maxLines: 1,
                      )
                    : Text(
                        'Пересмотрено: ${data.userRate!.rewatches.toString()}',
                        maxLines: 1,
                      ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // showDialog(
                  //   barrierDismissible: false,
                  //   context: context,
                  //   builder: (context) {
                  //     return AnimeUserRateDialog(anime: anime, data: data);
                  //   },
                  // );

                  showModalBottomSheet<void>(
                    context: context,
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width >= 700
                          ? 700
                          : double.infinity,
                    ),
                    useRootNavigator: true,
                    isScrollControlled: true,
                    enableDrag: false,
                    useSafeArea: true,
                    elevation: 0,
                    builder: (context) {
                      return AnimeUserRateBottomSheet(
                        data: data,
                        anime: anime,
                      );
                    },
                  );
                },
                child: data.userRate == null
                    ? const Text('Добавить в список')
                    : const Text('Изменить'),
              ),
            ),
            // if (data.userRate != null) ...[
            //   const SizedBox(
            //     width: 4,
            //   ),
            //   IconButton(
            //     onPressed: isLoading.value
            //         ? null
            //         : () async {
            //             isLoading.value = true;
            //             await incRate();

            //             // await ref
            //             //     .read(animeDataSourceProvider)
            //             //     .incrementUserRate(
            //             //       token: SecureStorageService.instance.token,
            //             //       rateId: data.userRate!.id!,
            //             //     );
            //             //ref.read(titleInfoPageProvider(data.id!)).fetch(true);

            //             isLoading.value = false;
            //           },
            //     icon: const Icon(Icons.exposure_plus_1),
            //   ),
            // ],
          ],
        ),
      ],
    );
  }
}

// enum UserList { watching, planned, completed, rewatching, onHold, dropped }

// extension UserListName on UserList {
//   String get name {
//     switch (this) {
//       case UserList.watching:
//         return 'Смотрю';
//       case UserList.planned:
//         return 'В планах';
//       case UserList.completed:
//         return 'Просмотрено';
//       case UserList.rewatching:
//         return 'Пересматриваю';
//       case UserList.onHold:
//         return 'Отложено';
//       case UserList.dropped:
//         return 'Брошено';
//     }
//   }
// }

final updateAnimeRateButtonProvider = StateNotifierProvider.autoDispose<
    UpdateAnimeRateNotifier, AsyncValue<void>>((ref) {
  return UpdateAnimeRateNotifier(
    ref: ref,
    animeRepository: ref.read(animeDataSourceProvider),
  );
}, name: 'updateAnimeRateButtonProvider');

class UpdateAnimeRateNotifier extends StateNotifier<AsyncValue<void>> {
  UpdateAnimeRateNotifier({required this.ref, required this.animeRepository})
      : super(const AsyncValue.data(null));

  final Ref ref;
  final AnimeRepository animeRepository;

  Future<void> createRate({
    required String selectedStatus,
    required int currentScore,
    required int progress,
    int? rewatches,
    String? text,
    required Animes anime,
    required VoidCallback onFinally,
  }) async {
    try {
      state = const AsyncValue.loading();

      final rate = await ref.read(userDataSourceProvider).createUserRate(
            token: SecureStorageService.instance.token,
            userId: int.parse(SecureStorageService.instance.userId),
            targetId: anime.id!,
            status: selectedStatus,
            score: currentScore,
            episodes: progress,
            rewatches: rewatches,
            text: text,
          );

      switch (rate.status) {
        case 'watching':
          {
            ref.read(watchingTabPageProvider).addAnime(
                  animeId: anime.id!,
                  anime: anime,
                  rateId: rate.id!,
                  createdAt: rate.createdAt!,
                  updatedAt: rate.updatedAt!,
                  score: rate.score,
                  episodes: rate.episodes,
                  rewatches: rate.rewatches,
                  status: rate.status,
                );
          }
          break;
        case 'planned':
          {
            ref.read(plannedTabPageProvider).addAnime(
                  animeId: anime.id!,
                  anime: anime,
                  rateId: rate.id!,
                  createdAt: rate.createdAt!,
                  updatedAt: rate.updatedAt!,
                  score: rate.score,
                  episodes: rate.episodes,
                  rewatches: rate.rewatches,
                  status: rate.status,
                );
            break;
          }
        case 'completed':
          {
            ref.read(completedTabPageProvider).addAnime(
                  animeId: anime.id!,
                  anime: anime,
                  rateId: rate.id!,
                  createdAt: rate.createdAt!,
                  updatedAt: rate.updatedAt!,
                  score: rate.score,
                  episodes: rate.episodes,
                  rewatches: rate.rewatches,
                  status: rate.status,
                );
          }
          break;
        case 'rewatching':
          {
            ref.read(rewatchingTabPageProvider).addAnime(
                  animeId: anime.id!,
                  anime: anime,
                  rateId: rate.id!,
                  createdAt: rate.createdAt!,
                  updatedAt: rate.updatedAt!,
                  score: rate.score,
                  episodes: rate.episodes,
                  rewatches: rate.rewatches,
                  status: rate.status,
                );
          }
          break;
        case 'on_hold':
          {
            ref.read(onHoldTabPageProvider).addAnime(
                  animeId: anime.id!,
                  anime: anime,
                  rateId: rate.id!,
                  createdAt: rate.createdAt!,
                  updatedAt: rate.updatedAt!,
                  score: rate.score,
                  episodes: rate.episodes,
                  rewatches: rate.rewatches,
                  status: rate.status,
                );
          }
          break;
        case 'dropped':
          {
            ref.read(droppedTabPageProvider).addAnime(
                  animeId: anime.id!,
                  anime: anime,
                  rateId: rate.id!,
                  createdAt: rate.createdAt!,
                  updatedAt: rate.updatedAt!,
                  score: rate.score,
                  episodes: rate.episodes,
                  rewatches: rate.rewatches,
                  status: rate.status,
                );
          }
          break;
        default:
      }

      ref.read(titleInfoPageProvider(anime.id!)).addRate(
            rateId: rate.id!,
            updatedAt: rate.updatedAt!,
            status: rate.status!,
            score: rate.score,
            episodes: rate.episodes,
            rewatches: rate.rewatches,
            text: rate.text,
            textHtml: rate.textHtml,
            createdAt: rate.createdAt,
          );

      onFinally();
    } catch (e, s) {
      state = AsyncValue.error('Ошибка создания отметки', s);
    } finally {
      state = const AsyncValue.data(null);
      //onFinally();
    }
  }

  Future<void> updateRate({
    required int rateId,
    required int animeId,
    required String selectedStatus,
    required String initStatus,
    int? currentScore,
    required int progress,
    int? rewatches,
    String? text,
    required Animes anime,
    required VoidCallback onFinally,
  }) async {
    try {
      state = const AsyncValue.loading();

      final rate = await ref.read(userDataSourceProvider).updateUserRate(
            token: SecureStorageService.instance.token,
            rateId: rateId,
            status: selectedStatus,
            score: currentScore,
            episodes: progress,
            rewatches: rewatches,
            text: text,
          );

      if (rate.status != initStatus) {
        switch (initStatus) {
          case 'watching':
            {
              ref.read(watchingTabPageProvider).deleteAnime(animeId);
            }
            break;
          case 'planned':
            {
              ref.read(plannedTabPageProvider).deleteAnime(animeId);
              break;
            }
          case 'completed':
            {
              ref.read(completedTabPageProvider).deleteAnime(animeId);
            }
            break;
          case 'rewatching':
            {
              ref.read(rewatchingTabPageProvider).deleteAnime(animeId);
            }
            break;
          case 'on_hold':
            {
              ref.read(onHoldTabPageProvider).deleteAnime(animeId);
            }
            break;
          case 'dropped':
            {
              ref.read(droppedTabPageProvider).deleteAnime(animeId);
            }
            break;
          default:
        }
        switch (rate.status) {
          case 'watching':
            {
              ref.read(watchingTabPageProvider).addAnime(
                    animeId: animeId,
                    anime: anime,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    episodes: rate.episodes,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          case 'planned':
            {
              ref.read(plannedTabPageProvider).addAnime(
                    animeId: animeId,
                    anime: anime,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    episodes: rate.episodes,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
              break;
            }
          case 'completed':
            {
              ref.read(completedTabPageProvider).addAnime(
                    animeId: animeId,
                    anime: anime,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    episodes: rate.episodes,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          case 'rewatching':
            {
              ref.read(rewatchingTabPageProvider).addAnime(
                    animeId: animeId,
                    anime: anime,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    episodes: rate.episodes,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          case 'on_hold':
            {
              ref.read(onHoldTabPageProvider).addAnime(
                    animeId: animeId,
                    anime: anime,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    episodes: rate.episodes,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          case 'dropped':
            {
              ref.read(droppedTabPageProvider).addAnime(
                    animeId: animeId,
                    anime: anime,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    episodes: rate.episodes,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          default:
        }
        ref.read(titleInfoPageProvider(animeId)).updateRate(
              rateId: rate.id!,
              updatedAt: rate.updatedAt!,
              status: rate.status!,
              score: rate.score,
              episodes: rate.episodes,
              rewatches: rate.rewatches,
              text: rate.text,
              textHtml: rate.textHtml,
              createdAt: rate.createdAt,
            );

        onFinally();

        return;
      }
      //switch (selectedStatus ?? initStatus) {
      switch (rate.status) {
        case 'watching':
          ref.read(watchingTabPageProvider).updateAnime(
                animeId: animeId,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                episodes: rate.episodes,
                rewatches: rate.rewatches,
              );
          break;
        case 'planned':
          ref.read(plannedTabPageProvider).updateAnime(
                animeId: animeId,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                episodes: rate.episodes,
                rewatches: rate.rewatches,
              );
          break;
        case 'completed':
          ref.read(completedTabPageProvider).updateAnime(
                animeId: animeId,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                episodes: rate.episodes,
                rewatches: rate.rewatches,
              );
          break;
        case 'rewatching':
          ref.read(rewatchingTabPageProvider).updateAnime(
                animeId: animeId,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                episodes: rate.episodes,
                rewatches: rate.rewatches,
              );
          break;
        case 'on_hold':
          ref.read(onHoldTabPageProvider).updateAnime(
                animeId: animeId,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                episodes: rate.episodes,
                rewatches: rate.rewatches,
              );
          break;
        case 'dropped':
          ref.read(droppedTabPageProvider).updateAnime(
                animeId: animeId,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                episodes: rate.episodes,
                rewatches: rate.rewatches,
              );
          break;
        default:
      }
      ref.read(titleInfoPageProvider(animeId)).updateRate(
            rateId: rate.id!,
            updatedAt: rate.updatedAt!,
            status: rate.status!,
            score: rate.score,
            episodes: rate.episodes,
            rewatches: rate.rewatches,
            text: rate.text,
            textHtml: rate.textHtml,
            createdAt: rate.createdAt,
          );
      onFinally();
    } catch (e, s) {
      state = AsyncValue.error('Ошибка обновления отметки', s);
    } finally {
      state = const AsyncValue.data(null);
      //onFinally();
    }
  }

  Future<void> deleteRate({
    required int rateId,
    required int animeId,
    required String status,
    required VoidCallback onFinally,
  }) async {
    try {
      state = const AsyncValue.loading();

      await ref.read(userDataSourceProvider).deleteUserRate(
            token: SecureStorageService.instance.token,
            rateId: rateId,
          );

      switch (status) {
        case 'watching':
          ref.read(watchingTabPageProvider).deleteAnime(animeId);
          break;
        case 'planned':
          ref.read(plannedTabPageProvider).deleteAnime(animeId);
          break;
        case 'completed':
          ref.read(completedTabPageProvider).deleteAnime(animeId);
          break;
        case 'rewatching':
          ref.read(rewatchingTabPageProvider).deleteAnime(animeId);
          break;
        case 'on_hold':
          ref.read(onHoldTabPageProvider).deleteAnime(animeId);
          break;
        case 'dropped':
          ref.read(droppedTabPageProvider).deleteAnime(animeId);
          break;
        default:
      }

      ref.read(titleInfoPageProvider(animeId)).deleteRate();

      onFinally();
    } catch (e, s) {
      state = AsyncValue.error('Ошибка удаления отметки', s);
    } finally {
      state = const AsyncValue.data(null);
      // onFinally();
    }
  }
}

class AnimeUserRateBottomSheet extends ConsumerStatefulWidget {
  final Anime data;
  final Animes anime;

  const AnimeUserRateBottomSheet({
    super.key,
    required this.data,
    required this.anime,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnimeUserRateBottomSheetState();
}

class _AnimeUserRateBottomSheetState
    extends ConsumerState<AnimeUserRateBottomSheet> {
  IconData getChipIcon(int index) {
    switch (index) {
      case 0:
        return Icons.remove_red_eye;
      case 1:
        return Icons.event_available;
      case 2:
        return Icons.done_all;
      case 3:
        return Icons.refresh;
      case 4:
        return Icons.pause;
      case 5:
        return Icons.close;
      default:
        return Icons.error;
    }
  }

  String getChipLabel(int value) {
    String label;

    const map = {
      0: 'Смотрю',
      1: 'В планах',
      2: 'Просмотрено',
      3: 'Пересматриваю',
      4: 'Отложено',
      5: 'Брошено'
    };

    label = map[value] ?? '?';

    return label;
  }

  int convertStatusStringToInt(String? value) {
    int status;

    const map = {
      'watching': 0,
      'planned': 1,
      'completed': 2,
      'rewatching': 3,
      'on_hold': 4,
      'dropped': 5,
    };

    status = map[value] ?? -1;

    return status;
  }

  String convertStatusIntToString(int value) {
    String status;

    const map = {
      0: 'watching',
      1: 'planned',
      2: 'completed',
      3: 'rewatching',
      4: 'on_hold',
      5: 'dropped',
    };

    status = map[value] ?? '';

    return status;
  }

  String getScorePrefix(int? score) {
    String text;

    const map = {
      0: 'Без оценки',
      1: 'Хуже некуда',
      2: 'Ужасно',
      3: 'Очень плохо',
      4: 'Плохо',
      5: 'Более-менее',
      6: 'Нормально',
      7: 'Хорошо',
      8: 'Отлично',
      9: 'Великолепно',
      10: 'Эпик Вин!',
    };

    text = map[score] ?? '';

    return text;
  }

  late TextEditingController _controller;

  String? initStatus;
  int? selectedStatus;

  int? currentScore;
  int rewatches = 0;
  int progress = 0;
  int epCount = 0;
  String userRateText = '';

  @override
  void initState() {
    initStatus = widget.data.userRate?.status;

    selectedStatus = convertStatusStringToInt(widget.data.userRate?.status);

    currentScore = widget.data.userRate?.score;
    rewatches = widget.data.userRate?.rewatches ?? 0;
    progress = widget.data.userRate?.episodes ?? 0;

    if (widget.data.status == 'released') {
      epCount = widget.data.episodes ?? 0;
    } else {
      epCount = widget.data.episodesAired ?? 0;
    }

    userRateText = widget.data.userRate?.text ?? '';
    _controller = TextEditingController();
    _controller.text = userRateText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      updateAnimeRateButtonProvider,
      (_, state) => state.whenOrNull(
        error: (error, stackTrace) {
          Navigator.of(context).pop();
          showErrorSnackBar(
            ctx: context,
            msg: error.toString(),
            // dur: const Duration(
            //   seconds: 4,
            // ),
          );
        },
      ),
    );

    final rateState = ref.watch(updateAnimeRateButtonProvider);
    final isLoading = rateState is AsyncLoading<void>;

    return WillPopScope(
      onWillPop: () async {
        //return true;
        return !isLoading;
      },
      child: SingleChildScrollView(
        child: Padding(
          padding:
              MediaQuery.of(context).viewInsets + const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Center(
              //   child: LayoutBuilder(
              //     builder: (ctx, constraints) {
              //       return Container(
              //         height: 4,
              //         width: constraints.maxWidth / 6,
              //         decoration: BoxDecoration(
              //           color: context.theme.colorScheme.onBackground,
              //           borderRadius: const BorderRadius.all(
              //             Radius.circular(8),
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
              // const SizedBox(
              //   height: 8,
              // ),
              Row(
                children: [
                  // CircleAvatar(
                  //   backgroundImage: ExtendedNetworkImageProvider(
                  //     AppConfig.staticUrl + widget.anime.image!.original!,
                  //   ),
                  // ),
                  // const SizedBox(
                  //   width: 8,
                  // ),
                  Text(
                    widget.data.russian ??
                        widget.data.name ??
                        '[Без навзвания]',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  children: List<Widget>.generate(
                    6,
                    (int index) {
                      return MaterialYouChip(
                        title: getChipLabel(index),
                        icon: getChipIcon(index),
                        onPressed: () {
                          setState(() {
                            selectedStatus = index;
                          });
                        },
                        isSelected: selectedStatus == index,
                      );
                    },
                  ).toList(),
                ),
              ),
              if (widget.data.userRate != null) ...[
                const SizedBox(
                  height: 16,
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          children: [
                            const Text('Прогресс:'),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              '$progress/${epCount.toString()}',
                            ),
                          ],
                        ),
                        Wrap(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (progress == 0) {
                                  return;
                                }
                                setState(() {
                                  progress = progress - 1;
                                });
                              },
                              icon: const Icon(Icons.remove),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            IconButton(
                              onPressed: () {
                                if (progress >= epCount) {
                                  return;
                                }
                                setState(() {
                                  progress = progress + 1;
                                });
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          children: [
                            const Text('Повторения:'),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(rewatches.toString()),
                          ],
                        ),
                        Wrap(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (rewatches == 0) {
                                  return;
                                }
                                setState(() {
                                  rewatches--;
                                });
                              },
                              icon: const Icon(Icons.remove),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  rewatches++;
                                });
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          children: [
                            const Text('Оценка:'),
                            const SizedBox(
                              width: 4,
                            ),
                            if (currentScore != null && currentScore != 0)
                              Text('$currentScore'),
                            const SizedBox(
                              width: 2,
                            ),
                            if (currentScore != null)
                              Text(
                                '(${getScorePrefix(currentScore)})',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(fontSize: 14),
                              ),
                          ],
                        ),
                        Wrap(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (currentScore == null) {
                                  return;
                                }
                                if (currentScore! <= 1) {
                                  return;
                                }
                                setState(() {
                                  currentScore = currentScore! - 1;
                                });
                              },
                              icon: const Icon(Icons.remove),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            IconButton(
                              onPressed: () {
                                if (currentScore == 10) {
                                  return;
                                }
                                setState(() {
                                  if (currentScore == null) {
                                    currentScore = 1;
                                    return;
                                  }
                                  currentScore = currentScore! + 1;
                                });
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Добавить заметку',
                  ),
                  maxLines: 3,
                ),
              ],
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      // style: FilledButton.styleFrom(
                      //   padding: const EdgeInsets.all(12.0),
                      // ),
                      onPressed: isLoading || selectedStatus == -1
                          ? null
                          : () {
                              if (widget.data.userRate == null) {
                                ref
                                    .read(
                                        updateAnimeRateButtonProvider.notifier)
                                    .createRate(
                                      anime: widget.anime,
                                      selectedStatus: convertStatusIntToString(
                                          selectedStatus!),
                                      currentScore: currentScore ?? 0,
                                      progress: progress,
                                      rewatches: rewatches,
                                      text: _controller.text,
                                      onFinally: () {
                                        Navigator.of(context).pop();

                                        showSnackBar(
                                          ctx: context,
                                          msg: 'Отметка создана',
                                          dur: const Duration(seconds: 3),
                                        );
                                      },
                                    );
                              } else {
                                ref
                                    .read(
                                        updateAnimeRateButtonProvider.notifier)
                                    .updateRate(
                                      rateId: widget.data.userRate!.id!,
                                      animeId: widget.data.id!,
                                      anime: widget.anime,
                                      selectedStatus: convertStatusIntToString(
                                          selectedStatus!),
                                      initStatus: initStatus!,
                                      currentScore: currentScore,
                                      progress: progress,
                                      rewatches: rewatches,
                                      text: _controller.text,
                                      onFinally: () {
                                        Navigator.of(context).pop();

                                        showSnackBar(
                                          ctx: context,
                                          msg: 'Отметка обновлена',
                                          dur: const Duration(seconds: 3),
                                        );
                                      },
                                    );
                              }
                            },
                      child: isLoading
                          ? const SizedBox.square(
                              dimension: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              widget.data.userRate == null
                                  ? 'Добавить'
                                  : 'Сохранить',
                            ),
                    ),
                  ),
                  if (widget.data.userRate != null &&
                      widget.data.userRate?.id != null &&
                      !isLoading)
                    IconButton(
                      tooltip: 'Удалить отметку',
                      onPressed: () {
                        ref
                            .read(updateAnimeRateButtonProvider.notifier)
                            .deleteRate(
                              rateId: widget.data.userRate!.id!,
                              animeId: widget.data.id!,
                              status: initStatus ?? '',
                              onFinally: () {
                                Navigator.of(context).pop();

                                showSnackBar(
                                  ctx: context,
                                  msg: 'Отметка удалена',
                                  dur: const Duration(seconds: 3),
                                );
                              },
                            );
                      },
                      icon: const Icon(Icons.delete),
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
