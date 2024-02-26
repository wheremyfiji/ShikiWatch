enum StreamQuality {
  fourK,
  fhd,
  hd,
  sd,
  low,
  idk;

  String get name {
    return switch (this) {
      StreamQuality.fourK => '2160p',
      StreamQuality.fhd => '1080p',
      StreamQuality.hd => '720p',
      StreamQuality.sd => '480p',
      StreamQuality.low => '360p',
      StreamQuality.idk => 'жесть ты придумал',
    };
  }
}
