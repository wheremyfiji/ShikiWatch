import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/data_sources/user_data_src.dart';
import '../../../domain/models/manga_ranobe.dart';
import '../../../domain/models/manga_short.dart';
import '../../../services/secure_storage/secure_storage_service.dart';
import '../../../utils/utils.dart';
import '../../providers/library_manga_provider.dart';
import '../../providers/manga_details_provider.dart';
import '../../widgets/delete_dialog.dart';
import '../../widgets/material_you_chip.dart';
import '../../widgets/number_field.dart';
import '../../widgets/shadowed_overflow_list.dart';

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
    fill();
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
          padding: MediaQuery.of(context).viewInsets +
              const EdgeInsets.only(top: 16, bottom: 16),
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
              const SizedBox(
                height: 10,
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
                      label: 'Главы:',
                      initial: progress,
                      maxValue: widget.data.status == 'released'
                          ? chaptersCount
                          : null,
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
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      //filled: true,
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
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: isLoading || selectedStatus == -1
                            ? null
                            : () {
                                if (widget.data.userRate == null) {
                                  ref
                                      .read(updateMangaRateButtonProvider
                                          .notifier)
                                      .createRate(
                                        mangaId: widget.manga.id!,
                                        manga: widget.manga,
                                        selectedStatus:
                                            convertStatusIntToString(
                                                selectedStatus!),
                                        onFinally: () {
                                          Navigator.of(context).pop();

                                          showSnackBar(
                                            ctx: context,
                                            msg:
                                                'Добавлено в список "${getChipLabel(selectedStatus ?? 0)}"',
                                            dur: const Duration(seconds: 3),
                                          );
                                        },
                                      );
                                } else {
                                  ref
                                      .read(updateMangaRateButtonProvider
                                          .notifier)
                                      .updateRate(
                                        rateId: widget.data.userRate!.id!,
                                        manga: widget.manga,
                                        selectedStatus:
                                            convertStatusIntToString(
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
                              .read(updateMangaRateButtonProvider.notifier)
                              .deleteRate(
                                rateId: widget.data.userRate!.id!,
                                mangaId: widget.manga.id!,
                                status: initStatus ?? '',
                                onFinally: () {
                                  Navigator.of(context).pop();

                                  showSnackBar(
                                    ctx: context,
                                    msg:
                                        'Удалено из списка "${getChipLabel(selectedStatus ?? 0)}"',
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
      state = AsyncValue.error('Ошибка при добавлении', s);
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
      state = AsyncValue.error('Ошибка при обновлении', s);
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
      state = AsyncValue.error('Ошибка при удалении', s);
    } finally {
      state = const AsyncValue.data(null);
    }
  }
}
