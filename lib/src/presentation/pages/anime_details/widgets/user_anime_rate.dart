import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../constants/config.dart';
import '../../../../utils/app_utils.dart';
import '../../../../data/data_sources/anime_data_src.dart';
import '../../../../data/data_sources/user_data_src.dart';
import '../../../../data/repositories/anime_repo.dart';
import '../../../../domain/models/anime.dart';
import '../../../../domain/models/animes.dart';
import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/anime_details_provider.dart';
import '../../../providers/library_tab_page_provider.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/delete_dialog.dart';
import '../../../widgets/material_you_chip.dart';
import '../../../widgets/number_field.dart';
import '../../../widgets/shadowed_overflow_decorator.dart';

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

  static void show(BuildContext context,
      {required Anime anime, required bool update}) {
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
      ),
      useRootNavigator: true,
      isScrollControlled: true,
      enableDrag: false,
      useSafeArea: true,
      elevation: 0,
      builder: (_) => SafeArea(
        bottom: false,
        child: AnimeUserRateBottomSheet(
          data: anime,
          needUpdate: update,
        ),
      ),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnimeUserRateBottomSheetState();
}

class _AnimeUserRateBottomSheetState
    extends ConsumerState<AnimeUserRateBottomSheet> {
  late TextEditingController _controller;
  //late final GlobalKey _globalKey;

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
    final createdDate = DateFormat.yMMMd().format(created); //yMMMMd
    final createdTime = DateFormat.Hm().format(created);

    createdAt = '$createdDate ($createdTime)';

    final updated =
        DateTime.tryParse(widget.data.userRate?.updatedAt ?? '')?.toLocal() ??
            DateTime(1970);
    final updatedDate = DateFormat.yMMMd().format(updated);
    final updatedTime = DateFormat.Hm().format(updated);

    updatedAt = '$updatedDate ($updatedTime)';
  }

  @override
  void initState() {
    //_globalKey = GlobalKey();

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
          context.navigator.pop();
          showErrorSnackBar(
            ctx: context,
            msg: error.toString(),
          );
        },
      ),
    );

    final rateState = ref.watch(updateAnimeRateButtonProvider);
    final isLoading = rateState is AsyncLoading<void>;

    final canDelete = (widget.data.userRate != null &&
        widget.data.userRate?.id != null &&
        !isLoading);

    return WillPopScope(
      onWillPop: () async {
        return !isLoading;
      },
      child: Material(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(28.0),
          topLeft: Radius.circular(28.0),
        ),
        clipBehavior: Clip.hardEdge,
        child: SingleChildScrollView(
          padding: MediaQuery.of(context).viewInsets +
              const EdgeInsets.only(top: 16.0, bottom: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  bottom: 16.0,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: SizedBox(
                        height: 48,
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: CachedImage(
                            '${AppConfig.staticUrl}${widget.data.image?.original}',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Прогресс',
                            style: context.textTheme.titleMedium?.copyWith(
                              //height: 1.4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            (widget.data.russian == ''
                                    ? widget.data.name
                                    : widget.data.russian) ??
                                '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.normal,
                              //height: 1.2,
                              color: context.colorScheme.onBackground
                                  .withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed:
                          isLoading ? null : () => context.navigator.pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              ShadowedOverflowDecorator(
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
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    //bottom: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: UserRateNumberField(
                          label: 'Эпизоды',
                          initial: progress,
                          maxValue: epCount,
                          onChanged: (value) {
                            setState(() {
                              progress = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 16.0,
                      ),
                      Expanded(
                        flex: 2,
                        child: Card(
                          margin: const EdgeInsets.all(0),
                          elevation: 0,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: context.colorScheme.outline,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Повторения',
                                  style: context.textTheme.labelLarge,
                                ),
                                Text(
                                  '$rewatches',
                                  style: context.textTheme.headlineSmall,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton.filledTonal(
                                      onPressed: rewatches == 0
                                          ? null
                                          : () {
                                              setState(() {
                                                rewatches--;
                                              });
                                            },
                                      icon: const Icon(
                                        Icons.remove_rounded,
                                      ),
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry>(
                                          const EdgeInsets.all(0),
                                        ),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(
                                      width: 8.0,
                                    ),
                                    IconButton.filledTonal(
                                      onPressed: () => setState(() {
                                        rewatches++;
                                      }),
                                      icon: const Icon(
                                        Icons.add_rounded,
                                      ),
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry>(
                                          const EdgeInsets.all(0),
                                        ),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (currentScore != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          top: 16.0,
                        ),
                        child: Text(
                          'Оценка',
                          style: context.textTheme.labelLarge,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              min: 0,
                              max: 10,
                              divisions: 10,
                              value: currentScore!.toDouble(),
                              onChanged: (double value) {
                                setState(() {
                                  currentScore = value.toInt();
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 32, child: Text('$currentScore')),
                        ],
                      ),
                    ],
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  child: TextField(
                    minLines: 1,
                    maxLines: 1,
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Заметка',
                    ),
                  ),
                ),
                Material(
                  color: context.colorScheme.surface,
                  surfaceTintColor: context.colorScheme.surfaceTint,
                  shadowColor: Colors.transparent,
                  //borderRadius: BorderRadius.circular(12),
                  type: MaterialType.card,
                  clipBehavior: Clip.hardEdge,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                    child: Row(
                      children: [
                        if (createdAt != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.add,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$createdAt',
                                    style: context.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (updatedAt != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.edit,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$updatedAt',
                                      style: context.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        const Spacer(),
                        if (canDelete)
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
                            icon: const Icon(Icons.delete_rounded),
                            color: context.colorScheme.error,
                          ),
                        FloatingActionButton(
                          onPressed: isLoading
                              ? null
                              : () => ref
                                  .read(updateAnimeRateButtonProvider.notifier)
                                  .updateRate(
                                    needUpdate: widget.needUpdate,
                                    rateId: widget.data.userRate!.id!,
                                    animeId: widget.data.id!,
                                    anime: widget.data,
                                    selectedStatus: _convertStatusIntToString(
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
                                  ),
                          child: isLoading
                              ? const SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (widget.data.userRate == null)
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                    child: FilledButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      onPressed: isLoading || selectedStatus == -1
                          ? null
                          : () {
                              ref
                                  .read(updateAnimeRateButtonProvider.notifier)
                                  .createRate(
                                    needUpdate: widget.needUpdate,
                                    anime: widget.data,
                                    selectedStatus: _convertStatusIntToString(
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
                            },
                      child: isLoading
                          ? const SizedBox.square(
                              dimension: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Добавить',
                            ),
                    ),
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
        return Icons.remove_red_eye_rounded;
      case 1:
        return Icons.event_available_rounded;
      case 2:
        return Icons.done_all_rounded;
      case 3:
        return Icons.refresh_rounded;
      case 4:
        return Icons.pause_rounded;
      case 5:
        return Icons.close_rounded;
      default:
        return Icons.error_rounded;
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

  // static String _getScorePrefix(int? score) {
  //   String text;

  //   const map = {
  //     0: 'Без оценки',
  //     1: 'Хуже некуда',
  //     2: 'Ужасно',
  //     3: 'Очень плохо',
  //     4: 'Плохо',
  //     5: 'Более-менее',
  //     6: 'Нормально',
  //     7: 'Хорошо',
  //     8: 'Отлично',
  //     9: 'Великолепно',
  //     10: 'Эпик Вин!',
  //   };

  //   text = map[score] ?? '';

  //   return text;
  // }
}
