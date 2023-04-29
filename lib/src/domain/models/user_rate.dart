class UserRate {
  int? id;
  int? score;
  String? status;
  String? text;
  int? episodes;
  int? chapters;
  int? volumes;
  String? textHtml;
  int? rewatches;
  String? createdAt;
  String? updatedAt;

  UserRate(
      {this.id,
      this.score,
      this.status,
      this.text,
      this.episodes,
      this.chapters,
      this.volumes,
      this.textHtml,
      this.rewatches,
      this.createdAt,
      this.updatedAt});

  UserRate.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    score = json['score'];
    status = json['status'];
    text = json['text'];
    episodes = json['episodes'];
    chapters = json['chapters'];
    volumes = json['volumes'];
    textHtml = json['text_html'];
    rewatches = json['rewatches'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
