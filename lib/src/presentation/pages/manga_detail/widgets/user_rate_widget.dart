import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../data/data_sources/user_data_src.dart';
import '../../../../domain/models/manga_ranobe.dart';
import '../../../../domain/models/manga_short.dart';
import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../../../utils/utils.dart';
import '../../../providers/library_manga_provider.dart';
import '../../../providers/manga_details_provider.dart';
import '../../../widgets/cool_chip.dart';
import '../../../widgets/material_you_chip.dart';

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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start, //end
          spacing: 8,
          runSpacing: 0,
          children: [
            CoolChip(
              label: getRateStatus(data.userRate!.status!),
            ),
            // CoolChip(
            //   label: 'Тома: ${data.userRate!.volumes.toString()}',
            // ),
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
    );
  }
}

class MangaUserRateBottomSheet extends ConsumerStatefulWidget {
  final MangaShort manga;
  final MangaRanobe data;

  const MangaUserRateBottomSheet({
    super.key,
    required this.manga,
    required this.data,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MangaUserRateBottomSheetState();
}

class _MangaUserRateBottomSheetState
    extends ConsumerState<MangaUserRateBottomSheet> {
  IconData getChipIcon(int index) {
    switch (index) {
      case 0:
        return Icons.auto_stories;
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
      0: 'Читаю',
      1: 'В планах',
      2: 'Прочитано',
      3: 'Перечитываю',
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
  //int epCount = 0;
  int chaptersCount = 0;
  String userRateText = '';

  @override
  void initState() {
    initStatus = widget.data.userRate?.status;

    selectedStatus = convertStatusStringToInt(widget.data.userRate?.status);

    currentScore = widget.data.userRate?.score;
    rewatches = widget.data.userRate?.rewatches ?? 0;
    progress = widget.data.userRate?.chapters ?? 0;

    if (widget.data.status == 'released') {
      chaptersCount = widget.data.chapters ?? 0;
    } else {
      chaptersCount = 0;
    }

    userRateText = widget.data.userRate?.text ?? '';
    _controller = TextEditingController();
    _controller.text = userRateText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      updateMangaRateButtonProvider,
      (_, state) => state.whenOrNull(
        error: (error, stackTrace) {
          Navigator.of(context).pop();
          showErrorSnackBar(
            ctx: context,
            msg: error.toString(),
          );
        },
      ),
    );
    final rateState = ref.watch(updateMangaRateButtonProvider);
    final isLoading = rateState is AsyncLoading<void>;

    return WillPopScope(
      onWillPop: () async {
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
              Text(
                (widget.data.russian == ''
                        ? widget.data.name
                        : widget.data.russian) ??
                    '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
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
                          setState(
                            () {
                              selectedStatus = index;
                            },
                          );
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
                            const Text('Главы:'),
                            const SizedBox(
                              width: 4,
                            ),
                            chaptersCount == 0
                                ? Text(
                                    '$progress',
                                  )
                                : Text(
                                    '$progress/${chaptersCount.toString()}',
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
                                if (chaptersCount != 0 &&
                                    progress >= chaptersCount) {
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
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: isLoading || selectedStatus == -1
                          ? null
                          : () {
                              if (widget.data.userRate == null) {
                                ref
                                    .read(
                                        updateMangaRateButtonProvider.notifier)
                                    .createRate(
                                      mangaId: widget.manga.id!,
                                      manga: widget.manga,
                                      selectedStatus: convertStatusIntToString(
                                          selectedStatus!),
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
                                        updateMangaRateButtonProvider.notifier)
                                    .updateRate(
                                      rateId: widget.data.userRate!.id!,
                                      manga: widget.manga,
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
                            .read(updateMangaRateButtonProvider.notifier)
                            .deleteRate(
                              rateId: widget.data.userRate!.id!,
                              mangaId: widget.manga.id!,
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

final updateMangaRateButtonProvider = StateNotifierProvider.autoDispose<
    UpdatMangaRateNotifierNotifier, AsyncValue<void>>((ref) {
  return UpdatMangaRateNotifierNotifier(
    ref: ref,
  );
}, name: 'updateMangaRateButtonProvider');

class UpdatMangaRateNotifierNotifier extends StateNotifier<AsyncValue<void>> {
  UpdatMangaRateNotifierNotifier({required this.ref})
      : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> createRate({
    required int mangaId,
    required MangaShort manga,
    required String selectedStatus,
    required VoidCallback onFinally,
  }) async {
    try {
      state = const AsyncValue.loading();

      final rate = await ref.read(userDataSourceProvider).createUserRate(
            token: SecureStorageService.instance.token,
            userId: int.parse(SecureStorageService.instance.userId),
            targetId: mangaId,
            status: selectedStatus,
            targetType: 'Manga',
          );

      switch (rate.status) {
        case 'watching':
          {
            ref.read(readingMangaTabProvider).addManga(
                  mangaInfo: manga,
                  rateId: rate.id!,
                  createdAt: rate.createdAt!,
                  updatedAt: rate.updatedAt!,
                  score: rate.score,
                  chapters: rate.chapters,
                  rewatches: rate.rewatches,
                  status: rate.status,
                );
          }
          break;
        case 'planned':
          {
            ref.read(plannedMangaTabProvider).addManga(
                  mangaInfo: manga,
                  rateId: rate.id!,
                  createdAt: rate.createdAt!,
                  updatedAt: rate.updatedAt!,
                  score: rate.score,
                  chapters: rate.chapters,
                  rewatches: rate.rewatches,
                  status: rate.status,
                );
            break;
          }
        case 'completed':
          {
            ref.read(completedMangaTabProvider).addManga(
                  mangaInfo: manga,
                  rateId: rate.id!,
                  createdAt: rate.createdAt!,
                  updatedAt: rate.updatedAt!,
                  score: rate.score,
                  chapters: rate.chapters,
                  rewatches: rate.rewatches,
                  status: rate.status,
                );
          }
          break;
        case 'rewatching':
          {
            ref.read(reReadingMangaTabProvider).addManga(
                  mangaInfo: manga,
                  rateId: rate.id!,
                  createdAt: rate.createdAt!,
                  updatedAt: rate.updatedAt!,
                  score: rate.score,
                  chapters: rate.chapters,
                  rewatches: rate.rewatches,
                  status: rate.status,
                );
          }
          break;
        case 'on_hold':
          {
            ref.read(onHoldMangaTabProvider).addManga(
                  mangaInfo: manga,
                  rateId: rate.id!,
                  createdAt: rate.createdAt!,
                  updatedAt: rate.updatedAt!,
                  score: rate.score,
                  chapters: rate.chapters,
                  rewatches: rate.rewatches,
                  status: rate.status,
                );
          }
          break;
        case 'dropped':
          {
            ref.read(droppedMangaTabProvider).addManga(
                  mangaInfo: manga,
                  rateId: rate.id!,
                  createdAt: rate.createdAt!,
                  updatedAt: rate.updatedAt!,
                  score: rate.score,
                  chapters: rate.chapters,
                  rewatches: rate.rewatches,
                  status: rate.status,
                );
          }
          break;
        default:
      }

      ref.read(mangaDetailsPageProvider(mangaId)).addRate(
            rateId: rate.id!,
            updatedAt: rate.updatedAt!,
            status: rate.status!,
            score: rate.score,
            chapters: rate.chapters,
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
    }
  }

  Future<void> updateRate({
    required MangaShort manga,
    required int rateId,
    required String initStatus,
    required String selectedStatus,
    required int progress,
    required VoidCallback onFinally,
    int? currentScore,
    int? rewatches,
    String? text,
  }) async {
    try {
      state = const AsyncValue.loading();

      final rate = await ref.read(userDataSourceProvider).updateUserRate(
            token: SecureStorageService.instance.token,
            rateId: rateId,
            status: selectedStatus,
            score: currentScore,
            chapters: progress,
            rewatches: rewatches,
            text: text,
          );

      /// если статус изменился
      if (rate.status != initStatus) {
        switch (initStatus) {
          case 'watching':
            {
              ref.read(readingMangaTabProvider).deleteManga(manga.id!);
            }
            break;
          case 'planned':
            {
              ref.read(plannedMangaTabProvider).deleteManga(manga.id!);
              break;
            }
          case 'completed':
            {
              ref.read(completedMangaTabProvider).deleteManga(manga.id!);
            }
            break;
          case 'rewatching':
            {
              ref.read(reReadingMangaTabProvider).deleteManga(manga.id!);
            }
            break;
          case 'on_hold':
            {
              ref.read(onHoldMangaTabProvider).deleteManga(manga.id!);
            }
            break;
          case 'dropped':
            {
              ref.read(droppedMangaTabProvider).deleteManga(manga.id!);
            }
            break;
          default:
        }
        switch (rate.status) {
          case 'watching':
            {
              ref.read(readingMangaTabProvider).addManga(
                    mangaInfo: manga,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    chapters: rate.chapters,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          case 'planned':
            {
              ref.read(plannedMangaTabProvider).addManga(
                    mangaInfo: manga,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    chapters: rate.chapters,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
              break;
            }
          case 'completed':
            {
              ref.read(completedMangaTabProvider).addManga(
                    mangaInfo: manga,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    chapters: rate.chapters,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          case 'rewatching':
            {
              ref.read(reReadingMangaTabProvider).addManga(
                    mangaInfo: manga,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    chapters: rate.chapters,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          case 'on_hold':
            {
              ref.read(onHoldMangaTabProvider).addManga(
                    mangaInfo: manga,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    chapters: rate.chapters,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          case 'dropped':
            {
              ref.read(droppedMangaTabProvider).addManga(
                    mangaInfo: manga,
                    rateId: rate.id!,
                    createdAt: rate.createdAt!,
                    updatedAt: rate.updatedAt!,
                    score: rate.score,
                    chapters: rate.chapters,
                    rewatches: rate.rewatches,
                    status: rate.status,
                  );
            }
            break;
          default:
        }
        ref.read(mangaDetailsPageProvider(manga.id!)).updateRate(
              rateId: rate.id!,
              updatedAt: rate.updatedAt!,
              status: rate.status!,
              score: rate.score,
              chapters: rate.chapters,
              rewatches: rate.rewatches,
              text: rate.text,
              textHtml: rate.textHtml,
              createdAt: rate.createdAt,
            );

        onFinally();
        return;
      }

      switch (rate.status) {
        case 'watching':
          ref.read(readingMangaTabProvider).updateManga(
                mangaId: manga.id!,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                chapters: rate.chapters,
                rewatches: rate.rewatches,
              );
          break;
        case 'planned':
          ref.read(plannedMangaTabProvider).updateManga(
                mangaId: manga.id!,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                chapters: rate.chapters,
                rewatches: rate.rewatches,
              );
          break;
        case 'completed':
          ref.read(completedMangaTabProvider).updateManga(
                mangaId: manga.id!,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                chapters: rate.chapters,
                rewatches: rate.rewatches,
              );
          break;
        case 'rewatching':
          ref.read(reReadingMangaTabProvider).updateManga(
                mangaId: manga.id!,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                chapters: rate.chapters,
                rewatches: rate.rewatches,
              );
          break;
        case 'on_hold':
          ref.read(onHoldMangaTabProvider).updateManga(
                mangaId: manga.id!,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                chapters: rate.chapters,
                rewatches: rate.rewatches,
              );
          break;
        case 'dropped':
          ref.read(droppedMangaTabProvider).updateManga(
                mangaId: manga.id!,
                updatedAt: rate.updatedAt!,
                score: rate.score,
                chapters: rate.chapters,
                rewatches: rate.rewatches,
              );
          break;
        default:
      }

      ref.read(mangaDetailsPageProvider(manga.id!)).updateRate(
            rateId: rate.id!,
            updatedAt: rate.updatedAt!,
            status: rate.status!,
            score: rate.score,
            chapters: rate.chapters,
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
    }
  }

  Future<void> deleteRate({
    required int rateId,
    required int mangaId,
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
          ref.read(readingMangaTabProvider).deleteManga(mangaId);
          break;
        case 'planned':
          ref.read(plannedMangaTabProvider).deleteManga(mangaId);
          break;
        case 'completed':
          ref.read(completedMangaTabProvider).deleteManga(mangaId);
          break;
        case 'rewatching':
          ref.read(reReadingMangaTabProvider).deleteManga(mangaId);
          break;
        case 'on_hold':
          ref.read(onHoldMangaTabProvider).deleteManga(mangaId);
          break;
        case 'dropped':
          ref.read(droppedMangaTabProvider).deleteManga(mangaId);
          break;
        default:
      }

      ref.read(mangaDetailsPageProvider(mangaId)).deleteRate();

      onFinally();
    } catch (e, s) {
      state = AsyncValue.error('Ошибка удаления отметки', s);
    } finally {
      state = const AsyncValue.data(null);
    }
  }
}
