import '../enums/topic_linked_type.dart';

import 'user.dart';

class ShikiTopic {
  final int id;
  final String topicTitle;
  final String body;
  final String htmlBody;
  final String htmlFooter;
  final DateTime createdAt;
  final int commentsCount;
  final ShikiForum forum;
  final User user;
  final String type;
  final int? linkedId;
  final LinkedType linkedType;
  //final Linked linked;
  final bool? viewed;
  final bool? lastCommentViewed;
  final String? event;
  //final int? episode;

  ShikiTopic({
    required this.id,
    required this.topicTitle,
    required this.body,
    required this.htmlBody,
    required this.htmlFooter,
    required this.createdAt,
    required this.commentsCount,
    required this.forum,
    required this.user,
    required this.type,
    required this.linkedId,
    required this.linkedType,
    //required this.linked,
    required this.viewed,
    required this.lastCommentViewed,
    required this.event,
    //required this.episode,
  });

  factory ShikiTopic.fromJson(Map<String, dynamic> json) => ShikiTopic(
        id: json["id"],
        topicTitle: json["topic_title"],
        body: json["body"],
        htmlBody: json["html_body"],
        htmlFooter: json["html_footer"],
        createdAt: DateTime.parse(json["created_at"]),
        commentsCount: json["comments_count"],
        forum: ShikiForum.fromJson(json["forum"]),
        user: User.fromJson(json["user"]),
        type: json["type"],
        linkedId: json["linked_id"],
        //linkedType: json["linked_type"],
        linkedType: LinkedType.fromValue(json["linked_type"]),
        //linked: Linked.fromJson(json["linked"]),
        viewed: json["viewed"],
        lastCommentViewed: json["last_comment_viewed"],
        event: json["event"],
        //episode: json["episode"],
      );
}

class ShikiForum {
  final int id;
  final int position;
  final String name;
  final String? permalink;
  final String? url;

  ShikiForum({
    required this.id,
    required this.position,
    required this.name,
    required this.permalink,
    required this.url,
  });

  factory ShikiForum.fromJson(Map<String, dynamic> json) => ShikiForum(
        id: json["id"],
        position: json["position"],
        name: json["name"],
        permalink: json["permalink"],
        url: json["url"],
      );
}
