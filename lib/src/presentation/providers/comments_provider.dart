import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shikidev/src/utils/extensions/riverpod_extensions.dart';

import '../../data/data_sources/comment_data_src.dart';
import '../../data/repositories/comment_repo.dart';
import '../../domain/models/shiki_comment.dart';
import '../../services/secure_storage/secure_storage_service.dart';

final commentsPageProvider = ChangeNotifierProvider.autoDispose
    .family<CommentsPageController, int>((ref, id) {
  final cancelToken = ref.cancelToken();

  final c = CommentsPageController(
    id: id,
    commentRepository: ref.read(commentDataSourceProvider),
    cancelToken: cancelToken,
  );

  ref.onDispose(() {
    c.pageController.dispose();
  });

  return c;
}, name: 'commentsPageProvider');

class CommentsPageController extends ChangeNotifier {
  CommentsPageController({
    required this.id,
    required this.commentRepository,
    required this.cancelToken,
  }) {
    _pagingController.addPageRequestListener((pageKey) {
      _fetch(pageKey);
    });
  }

  final CommentRepository commentRepository;
  final CancelToken cancelToken;
  final int id;

  final PagingController<int, ShikiComment> _pagingController =
      PagingController(firstPageKey: 1);

  static const _limit = 30;

  PagingController<int, ShikiComment> get pageController => _pagingController;

  Future<void> _fetch(int pageKey) async {
    try {
      final data = await commentRepository.getComments(
        commentableId: id,
        commentableType: 'Topic',
        page: pageKey,
        limit: _limit,
        //desc: 0,
        userToken: SecureStorageService.instance.token,
        cancelToken: cancelToken,
      );

      final comments = data.toList();

      final isLastPage = comments.length < _limit;

      if (isLastPage) {
        _pagingController.appendLastPage(comments);
      } else {
        _pagingController.appendPage(comments, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }
}
