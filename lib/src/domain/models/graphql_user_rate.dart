import 'package:flutter/foundation.dart';

import '../enums/shiki_gql.dart';

@immutable
class GraphqlUserRate {
  final int id;
  final RateStatus status;
  final int episodes;
  final int rewatches;
  final int score;
  final String? text;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GraphqlUserRate({
    required this.id,
    required this.status,
    required this.episodes,
    required this.rewatches,
    required this.score,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GraphqlUserRate.fromJson(Map<String, dynamic> json) =>
      GraphqlUserRate(
        id: int.parse(json["id"]),
        status: RateStatus.fromValue(json["status"]),
        episodes: json["episodes"] ?? 0,
        rewatches: json["rewatches"] ?? 0,
        score: json["score"] ?? 0,
        text: json["text"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.tryParse(json["createdAt"]),
        updatedAt: json["createdAt"] == null
            ? null
            : DateTime.tryParse(json["updatedAt"]),
      );

  GraphqlUserRate copyWith({
    int? id,
    RateStatus? status,
    int? episodes,
    int? rewatches,
    int? score,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GraphqlUserRate(
      id: id ?? this.id,
      status: status ?? this.status,
      episodes: episodes ?? this.episodes,
      rewatches: rewatches ?? this.rewatches,
      score: score ?? this.score,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(covariant GraphqlUserRate other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.status == status &&
        other.episodes == episodes &&
        other.rewatches == rewatches &&
        other.score == score &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        status.hashCode ^
        episodes.hashCode ^
        rewatches.hashCode ^
        score.hashCode ^
        text.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
