import 'package:equatable/equatable.dart';

import 'player_page_extra.dart';

class PlayerProviderParameters extends Equatable {
  final PlayerPageExtra extra;

  const PlayerProviderParameters(this.extra);

  @override
  List<Object> get props => [extra];
}
