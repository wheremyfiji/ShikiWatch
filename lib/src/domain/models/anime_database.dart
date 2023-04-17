import 'package:isar/isar.dart';
//import 'package:copy_with_extension/copy_with_extension.dart';

part 'anime_database.g.dart';

//@CopyWith()
@embedded
class Episode {
  int? nubmer;
  String? timeStamp;
  bool? isComplete;
  String? additionalInfo;
  String? position;

  Episode({
    this.nubmer,
    this.timeStamp = '',
    this.isComplete = false,
    this.additionalInfo = '',
    this.position,
  });
}

@embedded
class Studio {
  int? id;
  String? name;
  String? type;

  DateTime? created;
  DateTime? updated;

  int lastEpisodeIndex = 0;

  //List<Episode> episodes = [];
  List<Episode>? episodes;
}

@collection
@Name("animeDatabase")
class AnimeDatabase {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late int shikimoriId;
  String? animeName;
  //String? animeRussianName;
  String? imageUrl;
  DateTime? lastUpdate;
  List<Studio>? studios;
}

// @embedded
// class FavouriteTitle {
//   String? romaji;
//   String? english;
//   String? native;
//   String? userPreferred;
// }

// @collection
// @Name("favourites")
// class Favourite {
//   Id id = Isar.autoIncrement;
//   late String aniId;
//   FavouriteTitle? title;
//   int? malId;
//   List<String>? synonyms;
//   bool? isAdult;
//   String? image;
//   String? cover;
//   String? description;
//   List<String>? genres;
//   String? season;
//   List<String>? studios;
//   String? subOrDub;
//   String? type;
//   String? status;
//   int? totalEpisodes;
//   int? releaseDate;
//   int? duration;
//   int? rating;
//   List<int> viewedEpisodes = [];
// }
