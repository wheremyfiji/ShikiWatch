import 'package:flutter/material.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../utils/extensions/date_time_ext.dart';
import '../../../services/secure_storage/secure_storage_service.dart';
import '../../../utils/extensions/riverpod_extensions.dart';
import '../../../data/data_sources/user_data_src.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../data/repositories/user_repo.dart';
import '../../../domain/models/user_history.dart';
import '../../../domain/models/pages_extra.dart';
import '../../../utils/shiki_utils.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';
import '../../../constants/config.dart';

class UserHistoryPage extends ConsumerWidget {
  final String userId;

  const UserHistoryPage(this.userId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(userHistoryPageProvider(userId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => controller.pageController.refresh(),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: const Text('История'),
              ),
              PagedSliverList<int, UserHistory>(
                pagingController: controller.pageController,
                builderDelegate: PagedChildBuilderDelegate<UserHistory>(
                  noItemsFoundIndicatorBuilder: (context) {
                    return const Center(child: Text('В истории пусто'));
                  },
                  firstPageErrorIndicatorBuilder: (context) {
                    return CustomErrorWidget(
                      controller.pageController.error.toString(),
                      () => controller.pageController.refresh(),
                    );
                  },
                  newPageErrorIndicatorBuilder: (context) {
                    return CustomErrorWidget(
                      controller.pageController.error.toString(),
                      () => controller.pageController.retryLastFailedRequest(),
                    );
                  },
                  itemBuilder: (context, historyItem, index) {
                    if (historyItem.target != null) {
                      return HistoryTargetItem(historyItem);
                    }

                    return HistoryInfoItem(historyItem);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryInfoItem extends StatelessWidget {
  final UserHistory historyItem;

  const HistoryInfoItem(this.historyItem, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.info,
            size: 32,
          ),
          const SizedBox(
            width: 16.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  historyItem.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  timeago.format(
                    historyItem.createdAt!,
                    locale: 'ru',
                  ),
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryTargetItem extends StatelessWidget {
  final UserHistory historyItem;

  const HistoryTargetItem(this.historyItem, {super.key});

  @override
  Widget build(BuildContext context) {
    // final createdAtString = DateFormat('yyyy-MM-dd в HH:mm')
    //     .format(historyItem.createdAt!.toLocal());

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: historyItem.target!.kind == null
              ? null
              : () {
                  final extra = TitleDetailsPageExtra(
                    id: historyItem.target!.id!,
                    label: (historyItem.target!.russian == ''
                            ? historyItem.target!.name
                            : historyItem.target!.russian) ??
                        '',
                  );

                  if (kindIsManga(historyItem.target!.kind!)) {
                    GoRouter.of(context).pushNamed(
                      'library_manga',
                      pathParameters: <String, String>{
                        'id': (historyItem.target!.id!).toString(),
                      },
                      extra: extra,
                    );

                    return;
                  }

                  GoRouter.of(context).pushNamed(
                    'library_anime',
                    pathParameters: <String, String>{
                      'id': (historyItem.target!.id!).toString(),
                    },
                    extra: extra,
                  );
                },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: AspectRatio(
                  aspectRatio: 0.703,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: CachedImage(
                      AppConfig.staticUrl +
                          (historyItem.target!.image?.original ??
                              historyItem.target!.image?.preview ??
                              ''),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (historyItem.target!.russian == ''
                              ? historyItem.target!.name
                              : historyItem.target!.russian) ??
                          '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Html(
                        data: historyItem.description,
                        style: {
                          "body": Style(
                            margin: Margins.all(0),
                          ),
                        },
                      ),
                    ),
                    if (historyItem.createdAt != null)
                      Text(
                        historyItem.createdAt!.convertToDaysAgo(),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              context.colorScheme.onBackground.withOpacity(0.8),
                        ),
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

final userHistoryPageProvider = ChangeNotifierProvider.autoDispose
    .family<UserHistoryNotifier, String>((ref, id) {
  final token = ref.cancelToken();

  final c = UserHistoryNotifier(
    userId: id,
    userRepository: ref.read(userDataSourceProvider),
    cancelToken: token,
  );

  ref.onDispose(() {
    c.pageController.dispose();
  });

  return c;
}, name: 'userHistoryPageProvider');

class UserHistoryNotifier extends ChangeNotifier {
  UserHistoryNotifier({
    required this.userId,
    required this.userRepository,
    required this.cancelToken,
  }) {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchApi(pageKey);
    });
  }
  final String userId;
  final UserRepository userRepository;
  final CancelToken cancelToken;

  final PagingController<int, UserHistory> _pagingController =
      PagingController(firstPageKey: 1);

  static const _limit = 30;

  PagingController<int, UserHistory> get pageController => _pagingController;

  Future<void> _fetchApi(int pageKey) async {
    try {
      final resp = await userRepository.getHistory(
        id: userId,
        token: SecureStorageService.instance.token,
        page: pageKey,
        limit: _limit,
        cancelToken: cancelToken,
      );

      final data = resp.toList();

      final isLastPage = data.length < _limit;

      if (isLastPage) {
        _pagingController.appendLastPage(data);
      } else {
        _pagingController.appendPage(data, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }
}
