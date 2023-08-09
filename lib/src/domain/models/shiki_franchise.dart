class ShikiFranchise {
  final List<FranchiseNode>? nodes;
  final int? currentId;

  ShikiFranchise({
    this.nodes,
    this.currentId,
  });

  factory ShikiFranchise.fromJson(Map<String, dynamic> json) => ShikiFranchise(
        nodes: json["nodes"] == null
            ? []
            : List<FranchiseNode>.from(
                json["nodes"]!.map((x) => FranchiseNode.fromJson(x))),
        currentId: json["current_id"],
      );
}

class FranchiseNode {
  final int? id;
  final int? date;
  final String? name;
  final String? imageUrl;
  final String? url;
  final int? year;
  final String? kind;
  final int? weight;

  FranchiseNode({
    this.id,
    this.date,
    this.name,
    this.imageUrl,
    this.url,
    this.year,
    this.kind,
    this.weight,
  });

  factory FranchiseNode.fromJson(Map<String, dynamic> json) => FranchiseNode(
        id: json["id"],
        date: json["date"],
        name: json["name"],
        imageUrl:
            // json["image_url"] == null
            //     ? null
            //     :
            json["image_url"]?.toString().replaceFirst('/x96/', '/original/'),
        url: json["url"],
        year: json["year"],
        kind: json["kind"],
        weight: json["weight"],
      );
}

// class Franchise {
//   List<Links>? links;
//   List<Nodes>? nodes;
//   int? currentId;

//   Franchise({this.links, this.nodes, this.currentId});

//   Franchise.fromJson(Map<String, dynamic> json) {
//     if (json['links'] != null) {
//       links = <Links>[];
//       json['links'].forEach((v) {
//         links!.add(Links.fromJson(v));
//       });
//     }
//     if (json['nodes'] != null) {
//       nodes = <Nodes>[];
//       json['nodes'].forEach((v) {
//         nodes!.add(Nodes.fromJson(v));
//       });
//     }
//     currentId = json['current_id'];
//   }
// }

// class Links {
//   int? id;
//   int? sourceId;
//   int? targetId;
//   int? source;
//   int? target;
//   int? weight;
//   String? relation;

//   Links(
//       {this.id,
//       this.sourceId,
//       this.targetId,
//       this.source,
//       this.target,
//       this.weight,
//       this.relation});

//   Links.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     sourceId = json['source_id'];
//     targetId = json['target_id'];
//     source = json['source'];
//     target = json['target'];
//     weight = json['weight'];
//     relation = json['relation'];
//   }
// }

// class Nodes {
//   int? id;
//   int? date;
//   String? name;
//   String? imageUrl;
//   String? url;
//   int? year;
//   String? kind;
//   int? weight;

//   Nodes(
//       {this.id,
//       this.date,
//       this.name,
//       this.imageUrl,
//       this.url,
//       this.year,
//       this.kind,
//       this.weight});

//   Nodes.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     date = json['date'];
//     name = json['name'];
//     imageUrl = json['image_url'];
//     url = json['url'];
//     year = json['year'];
//     kind = json['kind'];
//     weight = json['weight'];
//   }
// }
