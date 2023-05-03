class ExternalLink {
  int? id;
  String? kind;
  String? url;
  String? source;
  int? entryId;
  String? entryType;
  String? createdAt;
  String? updatedAt;
  String? importedAt;

  ExternalLink(
      {this.id,
      this.kind,
      this.url,
      this.source,
      this.entryId,
      this.entryType,
      this.createdAt,
      this.updatedAt,
      this.importedAt});

  ExternalLink.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kind = json['kind'];
    url = json['url'];
    source = json['source'];
    entryId = json['entry_id'];
    entryType = json['entry_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    importedAt = json['imported_at'];
  }
}
