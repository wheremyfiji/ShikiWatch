import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../utils/utils.dart';
import '../../../../data/data_sources/anime_data_src.dart';
import '../../../../data/data_sources/user_data_src.dart';
import '../../../../data/repositories/anime_repo.dart';
import '../../../../domain/models/anime.dart';
import '../../../../domain/models/animes.dart';
import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../../providers/anime_details_provider.dart';
import '../../../providers/library_tab_page_provider.dart';
import '../../../widgets/delete_dialog.dart';
import '../../../widgets/material_you_chip.dart';
import '../../../widgets/number_field.dart';
import '../../../widgets/shadowed_overflow_list.dart';

// class UserAnimeRateWidget extends HookConsumerWidget {
//   //final Animes anime;
//   final Anime data;
//   //final String imageUrl;

//   const UserAnimeRateWidget(
//       // this.anime,
//       this.data,
//       // this.imageUrl,
//       {super.key});

//   String getRateStatus(String value) {
//     String status;

//     const map = {
//       'planned': 'В планах',
//       'watching': 'Смотрю',
//       'rewatching': 'Пересматриваю',
//       'completed': 'Просмотрено',
//       'on_hold': 'Отложено',
//       'dropped': 'Брошено'
//     };

//     status = map[value] ?? '';

//     return status;
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     if (data.userRate == null) {
//       return SizedBox(
//         child: Card(
//           margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(24),
//               topRight: Radius.circular(24),
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               vertical: 8,
//               horizontal: 12,
//             ),
//             child: FilledButton.icon(
//               onPressed: () {
//                 _openBottomSheet(context);
//               },
//               icon: const Icon(Icons.add_rounded),
//               label: const Text('Добавить в список'),
//             ),
//           ),
//         ),
//       );
//     }

//     return SizedBox(
//       width: double.infinity,
//       child: Card(
//         //margin: EdgeInsets.zero,
//         margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(24),
//             topRight: Radius.circular(24),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(
//             vertical: 8,
//             horizontal: 12,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Wrap(
//                   direction: Axis.horizontal,
//                   alignment: WrapAlignment.start,
//                   crossAxisAlignment: WrapCrossAlignment.start,
//                   spacing: 8,
//                   runSpacing: 0,
//                   children: [
//                     CoolChip(
//                       label: getRateStatus(data.userRate!.status ?? ''),
//                     ),
//                     CoolChip(
//                       label: 'Эпизоды: ${data.userRate!.episodes.toString()}',
//                     ),
//                     CoolChip(
//                       label: 'Оценка: ${data.userRate!.score.toString()}',
//                     ),
//                     CoolChip(
//                       label:
//                           'Пересмотрено: ${data.userRate!.rewatches.toString()}',
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 width: double.infinity,
//                 child: FilledButton.icon(
//                   onPressed: () {
//                     _openBottomSheet(context);
//                   },
//                   icon: const Icon(Icons.edit_rounded),
//                   label: const Text('Изменить'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _openBottomSheet(BuildContext context) {
//     showModalBottomSheet<void>(
//       context: context,
//       constraints: BoxConstraints(
//         maxWidth:
//             MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
//       ),
//       useRootNavigator: true,
//       isScrollControlled: true,
//       enableDrag: false,
//       useSafeArea: true,
//       //elevation: 0,
//       builder: (context) {
//         return SafeArea(
//           child: AnimeUserRateBottomSheet(
//             needUpdate: true,
//             data: data,
//             //anime: anime,
//           ),
//         );
//       },
//     );
//   }
// }

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
    required bool needUpdate,
    required String selectedStatus,
    required int currentScore,
    required int progress,
    int? rewatches,
    String? text,
    required Anime anime,
    required VoidCallback onFinally,
  }) async {
    try {
      state = const AsyncValue.loading();

      final rate = await ref.read(userDataSourceProvider).createUserRate(
            token: SecureStorageService.instance.token,
            userId: int.parse(SecureStorageService.instance.userId),
            targetId: anime.id!,
            status: selectedStatus,
          );

      final animeShort = Animes(
        id: anime.id,
        name: anime.name,
        russian: anime.russian,
        url: anime.url,
        image: anime.image,
        kind: anime.kind,
        score: anime.score,
        status: anime.status,
        episodes: anime.episodes,
        episodesAired: anime.episodesAired,
        airedOn: anime.airedOn,
        releasedOn: anime.releasedOn,
      );

      switch (rate.status) {
        case 'watching':
          {
            ref.read(watchingTabPageProvider).addAnime(
                  animeId: anime.id!,
                  anime: animeShort,
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
                  anime: animeShort,
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
                  anime: animeShort,
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
                  anime: animeShort,
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
                  anime: animeShort,
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
                  anime: animeShort,
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

      if (needUpdate) {
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
      }

      onFinally();
    } catch (e, s) {
      state = AsyncValue.error('Ошибка при добавлении', s);
    } finally {
      state = const AsyncValue.data(null);
      //onFinally();
    }
  }

  Future<void> updateRate({
    required bool needUpdate,
    required int rateId,
    required int animeId,
    required String selectedStatus,
    required String initStatus,
    int? currentScore,
    required int progress,
    int? rewatches,
    String? text,
    required Anime anime,
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

      final animeShort = Animes(
        id: anime.id,
        name: anime.name,
        russian: anime.russian,
        url: anime.url,
        image: anime.image,
        kind: anime.kind,
        score: anime.score,
        status: anime.status,
        episodes: anime.episodes,
        episodesAired: anime.episodesAired,
        airedOn: anime.airedOn,
        releasedOn: anime.releasedOn,
      );

      /// если статус изменился
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
                    anime: animeShort,
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
                    anime: animeShort,
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
                    anime: animeShort,
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
                    anime: animeShort,
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
                    anime: animeShort,
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
                    anime: animeShort,
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
        if (needUpdate) {
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
        }

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
      if (needUpdate) {
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
      }
      onFinally();
    } catch (e, s) {
      state = AsyncValue.error('Ошибка при обновлении', s);
    } finally {
      state = const AsyncValue.data(null);
      //onFinally();
    }
  }

  Future<void> deleteRate({
    required bool needUpdate,
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

      if (needUpdate) ref.read(titleInfoPageProvider(animeId)).deleteRate();

      onFinally();
    } catch (e, s) {
      state = AsyncValue.error('Ошибка при удалении', s);
    } finally {
      state = const AsyncValue.data(null);
      // onFinally();
    }
  }
}

class AnimeUserRateBottomSheet extends ConsumerStatefulWidget {
  final Anime data;
  final bool needUpdate;

  const AnimeUserRateBottomSheet({
    super.key,
    required this.data,
    required this.needUpdate,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnimeUserRateBottomSheetState();
}

class _AnimeUserRateBottomSheetState
    extends ConsumerState<AnimeUserRateBottomSheet> {
  late TextEditingController _controller;

  String? initStatus;
  int? selectedStatus;

  int? currentScore;
  int rewatches = 0;
  int progress = 0;
  int epCount = 0;
  String userRateText = '';

  String? createdAt;
  String? updatedAt;

  void fill() {
    if (widget.data.userRate == null) {
      return;
    }

    final created =
        DateTime.tryParse(widget.data.userRate?.createdAt ?? '')?.toLocal() ??
            DateTime(1970);
    final createdDate = DateFormat.yMMMMd().format(created);
    final createdTime = DateFormat.Hm().format(created);

    createdAt = '$createdDate в $createdTime';

    final updated =
        DateTime.tryParse(widget.data.userRate?.updatedAt ?? '')?.toLocal() ??
            DateTime(1970);
    final updatedDate = DateFormat.yMMMMd().format(updated);
    final updatedTime = DateFormat.Hm().format(updated);

    updatedAt = '$updatedDate в $updatedTime';
  }

  @override
  void initState() {
    initStatus = widget.data.userRate?.status;

    selectedStatus = _convertStatusStringToInt(widget.data.userRate?.status);

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
    fill();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
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
        return !isLoading;
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: MediaQuery.of(context).viewInsets +
              const EdgeInsets.only(top: 16, bottom: 16),
          //MediaQuery.of(context).viewInsets + const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 10, bottom: 10),
                child: Text(
                  (widget.data.russian == ''
                          ? widget.data.name
                          : widget.data.russian) ??
                      '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ShadowedOverflowList(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      const SizedBox(
                        width: 8.0,
                      ),
                      ...List<Widget>.generate(
                        6,
                        (int index) {
                          return MaterialYouChip(
                            title: _getChipLabel(index),
                            icon: _getChipIcon(index),
                            onPressed: () {
                              setState(
                                () {
                                  selectedStatus = index;
                                },
                              );
                            },
                            isSelected: selectedStatus == index,
                          );
                        },
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.data.userRate != null) ...[
                const SizedBox(
                  height: 16,
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 16,
                    ),
                    child: NumberField(
                      label: 'Эпизоды:',
                      initial: progress,
                      maxValue: epCount,
                      onChanged: (value) {
                        setState(() {
                          progress = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.zero),
                  ),
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
                              onPressed: rewatches == 0
                                  ? null
                                  : () {
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
                  height: 8,
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
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
                                '(${_getScorePrefix(currentScore)})',
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
                              onPressed: currentScore == 10
                                  ? null
                                  : () {
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
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      hintText: 'Заметка',
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
              ],
              const SizedBox(
                height: 16,
              ),
              if (createdAt != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    shadowColor: Colors.transparent,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Создано $createdAt'),
                          const SizedBox(
                            height: 4,
                          ),
                          if (updatedAt != null) Text('Изменено $updatedAt'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: FilledButton(
                        // style: FilledButton.styleFrom(
                        //   padding: const EdgeInsets.all(12.0),
                        // ),

                        onPressed: isLoading || selectedStatus == -1
                            ? null
                            : () {
                                if (widget.data.userRate == null) {
                                  ref
                                      .read(updateAnimeRateButtonProvider
                                          .notifier)
                                      .createRate(
                                        needUpdate: widget.needUpdate,
                                        anime: widget.data,
                                        selectedStatus:
                                            _convertStatusIntToString(
                                                selectedStatus!),
                                        currentScore: currentScore ?? 0,
                                        progress: progress,
                                        rewatches: rewatches,
                                        text: _controller.text,
                                        onFinally: () {
                                          Navigator.of(context).pop();

                                          showSnackBar(
                                            ctx: context,
                                            msg:
                                                'Добавлено в список "${_getChipLabel(selectedStatus ?? 0)}"',
                                            dur: const Duration(seconds: 3),
                                          );
                                        },
                                      );
                                } else {
                                  ref
                                      .read(updateAnimeRateButtonProvider
                                          .notifier)
                                      .updateRate(
                                        needUpdate: widget.needUpdate,
                                        rateId: widget.data.userRate!.id!,
                                        animeId: widget.data.id!,
                                        anime: widget.data,
                                        selectedStatus:
                                            _convertStatusIntToString(
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
                                            msg: 'Сохранено успешно',
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
                        tooltip: 'Удалить из списка',
                        onPressed: () async {
                          bool value = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) =>
                                    const DeleteDialog(),
                              ) ??
                              false;

                          if (!value) {
                            return;
                          }

                          ref
                              .read(updateAnimeRateButtonProvider.notifier)
                              .deleteRate(
                                needUpdate: widget.needUpdate,
                                rateId: widget.data.userRate!.id!,
                                animeId: widget.data.id!,
                                status: initStatus ?? '',
                                onFinally: () {
                                  Navigator.of(context).pop();

                                  showSnackBar(
                                    ctx: context,
                                    msg:
                                        'Удалено из списка "${_getChipLabel(selectedStatus ?? 0)}"',
                                    dur: const Duration(seconds: 3),
                                  );
                                },
                              );
                        },
                        icon: const Icon(Icons.delete),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _getChipIcon(int index) {
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

  static String _getChipLabel(int value) {
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

  static int _convertStatusStringToInt(String? value) {
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

  static String _convertStatusIntToString(int value) {
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

  static String _getScorePrefix(int? score) {
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
}
