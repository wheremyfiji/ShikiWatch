import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../../../utils/extensions/riverpod_extensions.dart';
import '../../../../data/data_sources/comment_data_src.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/models/shiki_comment.dart';
import '../../../widgets/shiki_comment.dart';
import '../../comments/comments_page.dart';

final titleCommentsProvider = FutureProvider.family
    .autoDispose<List<ShikiComment>, int>((ref, commentableId) async {
  final cancelToken = ref.cancelToken();

  final commentRepository = ref.read(commentDataSourceProvider);

  final data = await commentRepository.getComments(
    commentableId: commentableId,
    commentableType: 'Topic',
    page: 1,
    limit: 5,
    userToken: SecureStorageService.instance.token,
    cancelToken: cancelToken,
  );

  return data.toList();
}, name: 'titleCommentsProvider');

class TitleComments extends ConsumerWidget {
  const TitleComments({
    super.key,
    required this.id,
    required this.count,
    required this.name,
  });

  final int id;
  final int count;

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(titleCommentsProvider(id));

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          ListTile(
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => CommentsPage(
                  topicId: id,
                  name: name,
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            ),
            title: Text(
              'Комментарии',
              style: context.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Последние ($count всего)',
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
          ),
          ...commentsAsync.when(
            data: (comments) {
              return List.generate(
                comments.length,
                (index) {
                  final bottom = index == comments.length - 1 ? 16.0 : 8.0;

                  return Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
                    child: ShikiCommentItem(comments[index]),
                  );
                },
              );
            },
            error: (_, __) => [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text('Ошибка при загрузке комментов..'),
              ),
            ],
            loading: () => [
              const Padding(
                padding: EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
