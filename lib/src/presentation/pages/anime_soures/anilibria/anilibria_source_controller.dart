import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../anilibria/anilibria_api.dart';
import '../../../../../anilibria/models/search.dart';

final anilibriaSearchProvider = FutureProvider.autoDispose
    .family<AnilibriaSearch, String>((ref, name) async {
  final res = await ref
      .read(anilibriaApiProvider(kAnilibriaApiUrl))
      .searchTitle(name: name);

  return res;
}, name: 'anilibriaSearchProvider');
