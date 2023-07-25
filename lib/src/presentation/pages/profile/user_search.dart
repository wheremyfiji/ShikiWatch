import 'package:flutter/material.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../utils/extensions/riverpod_extensions.dart';
import '../../../data/data_sources/user_data_src.dart';
import '../../../data/repositories/user_repo.dart';
import '../../../domain/models/user.dart';
import '../../../utils/debouncer.dart';
import '../../widgets/error_widget.dart';

class UserSearchPage extends ConsumerWidget {
  const UserSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(userSearchProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: controller.textEditingController,
            focusNode: controller.focusNode,
            onChanged: controller.onSearchChanged,
            onSubmitted: controller.onSearchSubmitted,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Поиск пользователей',
              suffixIcon: controller.textEditingController.text.isNotEmpty
                  ? GestureDetector(
                      child: const Icon(Icons.close),
                      onTap: () {
                        controller.clearQuery();
                      },
                    )
                  : null,
            ),
          ),
        ),
        body: controller.textEditingController.text.isEmpty
            ? null
            : PagedListView<int, User>(
                pagingController: controller.pageController,
                builderDelegate: PagedChildBuilderDelegate<User>(
                  itemBuilder: (context, user, index) {
                    return UserSearchItem(user);
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
                  noItemsFoundIndicatorBuilder: (context) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 32, horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              'Ничего не найдено',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class UserSearchItem extends StatelessWidget {
  final User user;

  const UserSearchItem(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    final userLastOnline =
        DateTime.tryParse(user.lastOnlineAt ?? '')?.toLocal() ?? DateTime(1970);
    //final date = DateFormat.yMd().format(userLastOnline);
    //final time = DateFormat.Hm().format(userLastOnline);

    return ListTile(
      onTap: () => context.push('/profile/${user.id!}', extra: user),
      leading: CircleAvatar(
        maxRadius: 32,
        backgroundColor: Colors.transparent,
        backgroundImage: CachedNetworkImageProvider(user.image?.x160 ?? ''),
      ),
      title: Text(
        user.nickname ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      //subtitle: Text('Был(а) в сети $date в $time'),
      subtitle: Text(
        'Послед. онлайн ${timeago.format(userLastOnline, locale: 'ru')}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

final userSearchProvider =
    ChangeNotifierProvider.autoDispose<UserSearchNotifier>((ref) {
  final cancelToken = ref.cancelToken();
  final c = UserSearchNotifier(ref.read(userDataSourceProvider), cancelToken);

  c.initState();

  ref.onDispose(() {
    c.textEditingController.dispose();
    c.pageController.dispose();
    c.focusNode.dispose();
    c.debouncer.dispose();
  });

  return c;
}, name: 'userSearchProvider');

class UserSearchNotifier extends ChangeNotifier {
  UserSearchNotifier(
    //this._ref,
    this.userRepository,
    this.cancelToken,
  ) : debouncer = Debouncer(delay: const Duration(milliseconds: 800));

  //final Ref _ref;
  final CancelToken cancelToken;
  final Debouncer debouncer;
  final UserRepository userRepository;

  final PagingController<int, User> _pagingController =
      PagingController(firstPageKey: 1);
  late TextEditingController textEditingController;
  late FocusNode _focusNode;

  PagingController<int, User> get pageController => _pagingController;
  FocusNode get focusNode => _focusNode;

  List<String> searchHistory = [];
  static const _limit = 25;

  void initState() {
    _focusNode = FocusNode();
    textEditingController = TextEditingController();

    _pagingController.addPageRequestListener((pageKey) {
      _fetch(pageKey);
    });

    _focusNode.requestFocus();
  }

  void onSearchChanged(String query) {
    if (query.isNotEmpty && query.length < 3) {
      return;
    }

    notifyListeners();

    debouncer.run(() {
      _pagingController.refresh();
    });
  }

  void onSearchSubmitted(String query) async {}

  void clearQuery() {
    textEditingController.clear();

    if (_pagingController.itemList != null) {
      _pagingController.itemList!.clear();
    }

    notifyListeners();
  }

  Future<void> _fetch(int pageKey) async {
    try {
      final data = await userRepository.getUsers(
        page: pageKey,
        limit: _limit,
        search: textEditingController.text != ''
            ? textEditingController.text
            : null,
        cancelToken: cancelToken,
      );
      final users = data.toList();
      final isLastPage = users.length < _limit;
      if (isLastPage) {
        _pagingController.appendLastPage(users);
      } else {
        _pagingController.appendPage(users, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }
}
