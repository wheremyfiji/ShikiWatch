class ShikiImage {
  final String? original;
  final String? preview;
  final String? x96;
  final String? x48;

  ShikiImage({
    required this.original,
    required this.preview,
    required this.x96,
    required this.x48,
  });

  ShikiImage.fromJson(Map<String, dynamic> json)
      : original = json['original'],
        preview = json['preview'],
        x96 = json['x96'],
        x48 = json['x48'];
}
