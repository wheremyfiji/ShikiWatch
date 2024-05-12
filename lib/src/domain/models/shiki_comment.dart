import 'user.dart';

class ShikiComment {
  final int id;
  final int userId;
  final int commentableId;
  final String? commentableType;
  final String? body;
  final String? htmlBody;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOfftopic;
  final bool isSummary;
  final bool canBeEdited;
  final User user;

  ShikiComment({
    required this.id,
    required this.userId,
    required this.commentableId,
    this.commentableType,
    this.body,
    this.htmlBody,
    required this.createdAt,
    required this.updatedAt,
    required this.isOfftopic,
    required this.isSummary,
    required this.canBeEdited,
    required this.user,
  });

  factory ShikiComment.fromJson(Map<String, dynamic> json) => ShikiComment(
        id: json['user_id'],
        userId: json['user_id'],
        commentableId: json['commentable_id'],
        commentableType: json['commentable_type'],
        body: json['body'],
        htmlBody: json['html_body'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        isOfftopic: json['is_offtopic'] ?? false,
        isSummary: json['is_summary'] ?? false,
        canBeEdited: json['can_be_edited'] ?? false,
        user: User.fromJson(json['user']),
      );

  // ShikiComment.fromJson(Map<String, dynamic> json) {
  //   id = json['id'];
  //   userId = json['user_id'];
  //   commentableId = json['commentable_id'];
  //   commentableType = json['commentable_type'];
  //   body = json['body'];
  //   htmlBody = json['html_body'];
  //   //createdAt = json['created_at'];
  //   //updatedAt = json['updated_at'];
  //   createdAt = DateTime.parse(json['created_at']);
  //   updatedAt = DateTime.parse(json['updated_at']);
  //   isOfftopic = json['is_offtopic'] ?? false;
  //   isSummary = json['is_summary'] ?? false;
  //   canBeEdited = json['can_be_edited'] ?? false;
  //   user = json['user'] != null ? User.fromJson(json['user']) : null;
  // }
}
