extension StringExt on String? {
  bool get isNull => this == null;

  bool get isBlank => isNull || this!.isEmpty;

  bool get isNotBlank => !isBlank;

  bool get isInt => isNull ? false : int.tryParse(this!) != null;

  bool? get tryParseBool => isNull ? null : (this!).toLowerCase() == 'true';

  double? get tryParseInt => isNull ? null : double.tryParse(this!);

  bool hasMatch(String pattern) =>
      (isNull) ? false : RegExp(pattern).hasMatch(this!);

  String? get capitalize {
    if (isNull) return null;
    if (this!.isEmpty) return this;
    return this!.split(' ').map((e) => e.capitalizeFirst).join(' ');
  }

  String? get capitalizeFirst {
    if (isNull) return null;
    if (this!.isEmpty) return this;
    return this![0].toUpperCase() + this!.substring(1).toLowerCase();
  }
}
