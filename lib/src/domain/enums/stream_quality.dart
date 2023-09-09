enum StreamQuality {
  fhd,
  hd,
  sd,
  low;

  String get name {
    return switch (this) {
      StreamQuality.fhd => '1080p',
      StreamQuality.hd => '720p',
      StreamQuality.sd => '480p',
      StreamQuality.low => '360p',
    };
  }
}
