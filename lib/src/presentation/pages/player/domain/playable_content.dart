import '../../../../domain/enums/stream_quality.dart';

class PlayableContent {
  PlayableContent({
    this.fourK,
    this.fhd,
    this.hd,
    this.sd,
    this.low,
    this.subs,
  });

  final String? fourK;
  final String? fhd;
  final String? hd;
  final String? sd;
  final String? low;
  final String? subs;

  String getMaxQ() => fourK ?? fhd ?? hd ?? sd ?? low!;

  String? getQ(StreamQuality q) => switch (q) {
        StreamQuality.fourK => fourK,
        StreamQuality.fhd => fhd,
        StreamQuality.hd => hd,
        StreamQuality.sd => sd,
        StreamQuality.low => low,
        StreamQuality.idk => low,
      };
}
