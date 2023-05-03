import 'user.dart';

class ShikiComment {
  int? id;
  int? userId;
  int? commentableId;
  String? commentableType;
  String? body;
  String? htmlBody;
  String? createdAt;
  String? updatedAt;
  bool? isOfftopic;
  bool? isSummary;
  bool? canBeEdited;
  User? user;

  ShikiComment(
      {this.id,
      this.userId,
      this.commentableId,
      this.commentableType,
      this.body,
      this.htmlBody,
      this.createdAt,
      this.updatedAt,
      this.isOfftopic,
      this.isSummary,
      this.canBeEdited,
      this.user});

  ShikiComment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    commentableId = json['commentable_id'];
    commentableType = json['commentable_type'];
    body = json['body'];
    htmlBody = json['html_body'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isOfftopic = json['is_offtopic'];
    isSummary = json['is_summary'];
    canBeEdited = json['can_be_edited'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
}
