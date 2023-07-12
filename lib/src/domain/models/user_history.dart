import 'shiki_title.dart';

class UserHistory {
  final int id;
  final DateTime? createdAt;
  final String description;
  final ShikiTitle? target;

  UserHistory({
    required this.id,
    this.createdAt,
    required this.description,
    this.target,
  });

  factory UserHistory.fromJson(Map<String, dynamic> json) => UserHistory(
        id: json["id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"]),
        description: json["description"],
        target:
            json["target"] == null ? null : ShikiTitle.fromJson(json["target"]),
      );
}
