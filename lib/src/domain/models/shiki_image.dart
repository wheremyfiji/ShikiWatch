class ShikiImage {
  final String? original;
  final String? preview;
  final String? x96;
  final String? x48;

  ShikiImage({
    this.original,
    this.preview,
    this.x96,
    this.x48,
  });

  factory ShikiImage.fromJson(Map<String, dynamic> json) => ShikiImage(
        original: json["original"],
        preview: json["preview"],
        x96: json["x96"],
        x48: json["x48"],
      );
}
