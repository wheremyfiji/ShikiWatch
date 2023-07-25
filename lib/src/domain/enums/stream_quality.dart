enum StreamQuality {
  fhd,
  hd,
  sd,
  low,
}

extension StreamQualityExt on StreamQuality {
  String get name {
    switch (this) {
      case StreamQuality.fhd:
        return '1080p';
      case StreamQuality.hd:
        return '720p';
      case StreamQuality.sd:
        return '480p';
      case StreamQuality.low:
        return '360p';
    }
  }
}
