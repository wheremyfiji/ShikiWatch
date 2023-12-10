import 'package:equatable/equatable.dart';

import '../../../../domain/enums/stream_quality.dart';
import '../../../../domain/models/anime_player_page_extra.dart';

class VideoLinks {
  final String? fhd;
  final String? hd;
  final String? sd;
  final String? low;

  VideoLinks({
    this.fhd,
    this.hd,
    this.sd,
    this.low,
  });

  String getMaxQ() => fhd ?? hd ?? sd ?? low!;

  String? getQ(StreamQuality q) => switch (q) {
        StreamQuality.fhd => fhd,
        StreamQuality.hd => hd,
        StreamQuality.sd => sd,
        StreamQuality.low => low,
        StreamQuality.idk => low,
      };
}

class PlayerProviderParameters extends Equatable {
  final PlayerPageExtra extra;

  const PlayerProviderParameters(this.extra);

  @override
  List<Object> get props => [extra];
}
