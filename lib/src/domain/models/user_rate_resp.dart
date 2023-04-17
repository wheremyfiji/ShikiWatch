// import 'dart:convert';

class UserRateResp {
  final int? id;
  final int? userId;
  final int? targetId;
  final String? targetType;
  final int? score;
  final String? status;
  final int? rewatches;
  final int? episodes;
  final int? volumes;
  final int? chapters;
  final String? text;
  final String? textHtml;
  final String? createdAt;
  final String? updatedAt;
  //Null? manga;

  UserRateResp({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.score,
    required this.status,
    required this.rewatches,
    required this.episodes,
    required this.volumes,
    required this.chapters,
    required this.text,
    required this.textHtml,
    required this.createdAt,
    required this.updatedAt,
    //this.manga
  });

  UserRateResp.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        targetId = json['target_id'],
        targetType = json['target_type'],
        score = json['score'],
        status = json['status'],
        rewatches = json['rewatches'],
        episodes = json['episodes'],
        volumes = json['volumes'],
        chapters = json['chapters'],
        text = json['text'],
        textHtml = json['text_html'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];
}

// class UserRateResp {
//   int? id;
//   int? userId;
//   int? targetId;
//   String? targetType;
//   int? score;
//   String? status;
//   int? rewatches;
//   int? episodes;
//   int? volumes;
//   int? chapters;
//   String? text;
//   String? textHtml;
//   String? createdAt;
//   String? updatedAt;
//   UserRateResp({
//     this.id,
//     this.userId,
//     this.targetId,
//     this.targetType,
//     this.score,
//     this.status,
//     this.rewatches,
//     this.episodes,
//     this.volumes,
//     this.chapters,
//     this.text,
//     this.textHtml,
//     this.createdAt,
//     this.updatedAt,
//   });

//   UserRateResp copyWith({
//     int? id,
//     int? userId,
//     int? targetId,
//     String? targetType,
//     int? score,
//     String? status,
//     int? rewatches,
//     int? episodes,
//     int? volumes,
//     int? chapters,
//     String? text,
//     String? textHtml,
//     String? createdAt,
//     String? updatedAt,
//   }) {
//     return UserRateResp(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       targetId: targetId ?? this.targetId,
//       targetType: targetType ?? this.targetType,
//       score: score ?? this.score,
//       status: status ?? this.status,
//       rewatches: rewatches ?? this.rewatches,
//       episodes: episodes ?? this.episodes,
//       volumes: volumes ?? this.volumes,
//       chapters: chapters ?? this.chapters,
//       text: text ?? this.text,
//       textHtml: textHtml ?? this.textHtml,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'id': id,
//       'userId': userId,
//       'targetId': targetId,
//       'targetType': targetType,
//       'score': score,
//       'status': status,
//       'rewatches': rewatches,
//       'episodes': episodes,
//       'volumes': volumes,
//       'chapters': chapters,
//       'text': text,
//       'textHtml': textHtml,
//       'createdAt': createdAt,
//       'updatedAt': updatedAt,
//     };
//   }

//   factory UserRateResp.fromMap(Map<String, dynamic> map) {
//     return UserRateResp(
//       id: map['id'] != null ? map['id'] as int : null,
//       userId: map['userId'] != null ? map['userId'] as int : null,
//       targetId: map['targetId'] != null ? map['targetId'] as int : null,
//       targetType:
//           map['targetType'] != null ? map['targetType'] as String : null,
//       score: map['score'] != null ? map['score'] as int : null,
//       status: map['status'] != null ? map['status'] as String : null,
//       rewatches: map['rewatches'] != null ? map['rewatches'] as int : null,
//       episodes: map['episodes'] != null ? map['episodes'] as int : null,
//       volumes: map['volumes'] != null ? map['volumes'] as int : null,
//       chapters: map['chapters'] != null ? map['chapters'] as int : null,
//       text: map['text'] != null ? map['text'] as String : null,
//       textHtml: map['textHtml'] != null ? map['textHtml'] as String : null,
//       createdAt: map['createdAt'] != null ? map['createdAt'] as String : null,
//       updatedAt: map['updatedAt'] != null ? map['updatedAt'] as String : null,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory UserRateResp.fromJson(String source) =>
//       UserRateResp.fromMap(json.decode(source) as Map<String, dynamic>);
// }
