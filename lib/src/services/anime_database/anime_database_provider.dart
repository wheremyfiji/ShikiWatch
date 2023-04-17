import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/anime_database_repo.dart';

final animeDatabaseProvider = Provider<LocalAnimeDatabaseRepo>(
    (ref) => throw UnimplementedError(),
    name: 'animeDatabaseProvider');
