import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/environment_repo.dart';

final environmentProvider = Provider<EnvironmentRepo>(
  (ref) => throw UnimplementedError(),
  name: 'environmentProvider',
);
