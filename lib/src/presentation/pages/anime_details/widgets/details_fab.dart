// import 'package:flutter/material.dart';

// import '../../../../domain/models/anime.dart';
// import '../../../../domain/models/animes.dart';
// import 'user_anime_rate.dart';

// class AnimeDetailsFAB extends StatelessWidget {
//   final Anime data;
//   final Animes animeData;

//   const AnimeDetailsFAB(
//       {super.key, required this.data, required this.animeData});

//   String getStatus(String value, int? c) {
//     String status;

//     const map = {
//       'planned': 'В планах',
//       'watching': 'Смотрю',
//       'rewatching': 'Пересматриваю',
//       'completed': 'Просмотрено',
//       'on_hold': 'Отложено',
//       'dropped': 'Брошено'
//     };

//     status = map[value] ?? '';

//     return (c != 0 && value == 'watching') ? '$status (Серия $c)' : status;
//   }

//   IconData getIcon(String value) {
//     IconData icon;

//     const map = {
//       'planned': Icons.event_available,
//       'watching': Icons.remove_red_eye,
//       'rewatching': Icons.refresh,
//       'completed': Icons.done_all,
//       'on_hold': Icons.pause,
//       'dropped': Icons.close
//     };

//     icon = map[value] ?? Icons.edit;

//     return icon;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton.extended(
//       onPressed: () => showModalBottomSheet<void>(
//         context: context,
//         constraints: BoxConstraints(
//           maxWidth:
//               MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
//         ),
//         useRootNavigator: true,
//         isScrollControlled: true,
//         enableDrag: false,
//         useSafeArea: true,
//         builder: (context) {
//           return SafeArea(
//             child: AnimeUserRateBottomSheet(
//               data: data,
//               anime: animeData,
//             ),
//           );
//         },
//       ),
//       label: data.userRate == null
//           ? const Text('Добавить в список')
//           : Text(getStatus(
//               data.userRate!.status ?? 'Изменить', data.userRate!.episodes)),
//       icon: data.userRate == null
//           ? const Icon(Icons.add)
//           : Icon(getIcon(data.userRate!.status ?? '')),
//     );
//   }
// }
