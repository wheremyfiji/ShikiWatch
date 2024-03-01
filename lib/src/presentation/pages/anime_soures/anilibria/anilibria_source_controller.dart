import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../anilibria/anilibria_api.dart';
import '../../../../../anilibria/models/search.dart';
import '../../../../utils/extensions/riverpod_extensions.dart';

final anilibriaSearchProvider = FutureProvider.autoDispose
    .family<AnilibriaSearch, String>((ref, name) async {
  final anilibriaApi = ref.read(anilibriaApiProvider(kAnilibriaApiUrl));
  final cancelToken = ref.cancelToken();

  final result = await anilibriaApi.searchTitle(
    name: name,
    cancelToken: cancelToken,
  );

  return result;
}, name: 'anilibriaSearchProvider');
