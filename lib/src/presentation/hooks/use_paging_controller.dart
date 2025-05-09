import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// vibecoding)))
PagingController<int, T> usePagination<T>({
  required int pageSize,
  required Future<List<T>> Function(int) fetchPage,
  int firstPageKey = 1,
}) {
  final PagingController<int, T> pagingController = useMemoized(
    () => PagingController<int, T>(firstPageKey: firstPageKey),
    //[fetchPage, pageSize, firstPageKey],
  );

  useEffect(
    () {
      pagingController.addPageRequestListener((pageKey) async {
        try {
          final newItems = await fetchPage(pageKey);
          final isLastPage = newItems.length < pageSize;
          if (isLastPage) {
            pagingController.appendLastPage(newItems);
          } else {
            pagingController.appendPage(newItems, pageKey + 1);
          }
        } catch (e) {
          pagingController.error = e;
        }
      });

      return pagingController.dispose;
    },
    [pagingController],
  );

  return pagingController;
}
