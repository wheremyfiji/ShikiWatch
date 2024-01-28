import 'package:flutter/foundation.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../data/data_sources/topics_data_src.dart';
import '../../../data/repositories/topics_repo.dart';
import '../../../domain/models/shiki_topic.dart';

final topicsPageProvider = ChangeNotifierProvider<TopicsPageController>((ref) {
  final c = TopicsPageController(
    topicsRepository: ref.read(topicsDataSourceProvider),
  );

  ref.onDispose(() {
    c.pageController.dispose();
  });

  return c;
}, name: 'topicsPageProvider');

class TopicsPageController extends ChangeNotifier {
  TopicsPageController({required this.topicsRepository}) {
    _pagingController.addPageRequestListener((pageKey) {
      _fetch(pageKey);
    });
  }

  final TopicsRepository topicsRepository;
  final PagingController<int, ShikiTopic> _pagingController =
      PagingController(firstPageKey: 1);

  static const _limit = 10;

  PagingController<int, ShikiTopic> get pageController => _pagingController;

  Future<void> _fetch(int pageKey) async {
    try {
      final data = await topicsRepository.getTopics(
        page: pageKey,
        limit: _limit,
        forum: 'news',
      );

      if (data.isNotEmpty) {
        data.removeLast();
      }

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
