// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:go_router/go_router.dart';

// import '../../../domain/models/anime.dart' show Videos, Screenshots;
// import '../../../services/preferences/preferences_service.dart';
// import '../../providers/anime_details_provider.dart';
// import '../../../utils/extensions/buildcontext.dart';
// import '../../widgets/image_with_shimmer.dart';
// import '../../widgets/title_description.dart';
// import '../../../domain/models/animes.dart';
// import '../../../utils/shiki_utils.dart';
// import '../../widgets/cached_image.dart';
// import '../../widgets/error_widget.dart';
// import '../../../constants/config.dart';
// import '../../../utils/utils.dart';

// import 'rating_dialog.dart';

// import 'widgets/anime_actions.dart';
// import 'widgets/anime_user_rate_dialog.dart';
// import 'widgets/rates_statuses_widget.dart';
// import 'widgets/related_widget.dart';

// //desktop
// class AnimeDetailsDesktopPage extends ConsumerWidget {
//   final Animes animeData;
//   const AnimeDetailsDesktopPage({super.key, required this.animeData});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final titleInfo = ref.watch(titleInfoPageProvider(animeData.id!));

//     List<String> getDate(String? airedOn, String? releasedOn) {
//       //String? date = releasedOn ?? airedOn;
//       String? date = airedOn;

//       if (date == null) {
//         return ['n/d', ''];
//       }

//       final splitted = date.split('-');
//       var month = int.parse(splitted[1]);

//       return [splitted[0], getSeason(month)];
//     }

//     final date = getDate(animeData.airedOn, animeData.releasedOn);
//     final year = date[0];
//     final season = date[1];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           animeData.russian ?? animeData.name ?? '[Без навзвания]',
//           style: context.theme.textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: context.theme.colorScheme.onBackground),
//         ),
//         actions: [
//           PopupMenuButton<int>(
//             tooltip: '',
//             itemBuilder: (context) {
//               return [
//                 const PopupMenuItem<int>(
//                   value: 1,
//                   child: Text("Открыть в браузере"),
//                 ),
//                 const PopupMenuItem<int>(
//                   value: 2,
//                   child: Text("Скопировать ссылку"),
//                 ),
//                 const PopupMenuDivider(),
//                 (titleInfo.isFavor)
//                     ? const PopupMenuItem<int>(
//                         value: 0,
//                         child: Text("Удалить из избранного"),
//                       )
//                     : const PopupMenuItem<int>(
//                         value: 0,
//                         child: Text("Добавить в избранное"),
//                       ),
//               ];
//             },
//             onSelected: (value) {
//               if (value == 0) {
//                 if (titleInfo.isFavor) {
//                   showSnackBar(
//                     ctx: context,
//                     msg: 'типа удалил',
//                   );
//                 } else {
//                   showSnackBar(
//                     ctx: context,
//                     msg: 'типа добавил',
//                   );
//                 }
//               } else if (value == 1) {
//                 launchUrlString(
//                   '${AppConfig.staticUrl}/animes/${animeData.id}',
//                   mode: LaunchMode.externalApplication,
//                 );
//               } else if (value == 2) {
//                 Clipboard.setData(
//                   ClipboardData(
//                     text: AppConfig.staticUrl + (animeData.url ?? ''),
//                   ),
//                 ).whenComplete(
//                   () {
//                     if (context.mounted) {
//                       showSnackBar(
//                         ctx: context,
//                         msg: 'Ссылка скопирована в буфер обмена',
//                       );
//                     }
//                   },
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     width: 200,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         AspectRatio(
//                           aspectRatio: 0.703,
//                           child:
//                               //Hero(
//                               //  tag: animeData.id!,
//                               //  child:
//                               ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Stack(
//                               fit: StackFit.expand,
//                               children: [
//                                 CachedImage(
//                                   AppConfig.staticUrl +
//                                       (animeData.image?.original ??
//                                           animeData.image?.preview ??
//                                           ''),
//                                   fit: BoxFit.cover,
//                                 ),
//                                 // CachedNetworkImage(
//                                 //   imageUrl: AppConfig.staticUrl +
//                                 //       (animeData.image?.original ??
//                                 //           animeData.image?.preview ??
//                                 //           ''),
//                                 //   fit: BoxFit.cover,
//                                 // ),
//                                 // ExtendedImage.network(
//                                 //   AppConfig.staticUrl +
//                                 //       (animeData.image?.original ??
//                                 //           animeData.image?.preview ??
//                                 //           ''),
//                                 //   fit: BoxFit.cover,
//                                 //   cache: true,
//                                 // ),
//                                 if (titleInfo.isFavor) ...[
//                                   const Align(
//                                     alignment: Alignment.bottomRight,
//                                     child: Padding(
//                                       padding: EdgeInsets.all(8.0),
//                                       child: Icon(
//                                         Icons.favorite,
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                           ),
//                         ),
//                         //),
//                         if (titleInfo.title.asData?.value.userRate != null) ...[
//                           const SizedBox(
//                             height: 8,
//                           ),
//                           Text(
//                             'Список: ${getRateStatus(titleInfo.title.asData!.value.userRate!.status!)}',
//                             maxLines: 1,
//                           ),
//                           Text(
//                             'Эпизоды: ${titleInfo.title.asData!.value.userRate!.episodes.toString()}',
//                             maxLines: 1,
//                           ),
//                           Text(
//                             'Пересмотрено: ${titleInfo.title.asData!.value.userRate!.rewatches.toString()}',
//                             maxLines: 1,
//                           ),
//                           Text(
//                             'Оценка: ${titleInfo.title.asData!.value.userRate!.score.toString()}',
//                             maxLines: 1,
//                           ),
//                           const SizedBox(
//                             height: 8,
//                           ),
//                           SizedBox(
//                             //width: 203,
//                             width: double.infinity,
//                             //width: 200,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 showDialog(
//                                   barrierDismissible: false,
//                                   context: context,
//                                   builder: (context) {
//                                     return AnimeUserRateDialog(
//                                       anime: animeData,
//                                       data: titleInfo.title.asData!.value,
//                                     );
//                                   },
//                                 );
//                               },
//                               // child: const Text('Добавить в список'),
//                               child: const Text('Изменить'),
//                             ),
//                           ),
//                         ],
//                         if (titleInfo.title.asData?.value.userRate == null &&
//                             !titleInfo.title.isLoading) ...[
//                           const SizedBox(
//                             height: 16,
//                           ),
//                           SizedBox(
//                             //width: 203,
//                             width: double.infinity,
//                             //width: 200,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 showDialog(
//                                   barrierDismissible: false,
//                                   context: context,
//                                   builder: (context) {
//                                     return AnimeUserRateDialog(
//                                       anime: animeData,
//                                       data: titleInfo.title.asData!.value,
//                                     );
//                                   },
//                                 );
//                               },
//                               child: const Text('Добавить в список'),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 16,
//                   ),
//                   Flexible(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Tooltip(
//                           message: titleInfo.nameEng,
//                           child: Text(
//                             animeData.russian ??
//                                 animeData.name ??
//                                 '[Без навзвания]',
//                             maxLines: 3,
//                             textAlign: TextAlign.start,
//                             overflow: TextOverflow.ellipsis,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleSmall!
//                                 .copyWith(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 2,
//                         ),
//                         Text(
//                           animeData.name ?? '',
//                           maxLines: 2,
//                           textAlign: TextAlign.start,
//                           overflow: TextOverflow.ellipsis,
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleSmall!
//                               .copyWith(fontWeight: FontWeight.normal),
//                         ),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         if (titleInfo.title.asData?.value.airedOn != null)
//                           Text(
//                             'Сезон: $year • $season',
//                             textAlign: TextAlign.start,
//                           ),
//                         Text(
//                           'Статус: ${getStatus(animeData.status!)} • ${getKind(animeData.kind!)}',
//                           textAlign: TextAlign.start,
//                         ),
//                         animeData.status == 'released'
//                             ? Text(
//                                 'Эпизоды: ${animeData.episodes!} эп. по ~${titleInfo.duration} мин.',
//                                 textAlign: TextAlign.start,
//                               )
//                             : Text(
//                                 'Эпизоды: ${animeData.episodesAired!} из ${animeData.episodes! == 0 ? '?' : '${animeData.episodes!}'} эп. по ~${titleInfo.duration} мин.',
//                                 textAlign: TextAlign.start,
//                               ),
//                         titleInfo.nextEp != null && titleInfo.nextEp != ''
//                             ? Text('След. серия: ${titleInfo.nextEp}',
//                                 textAlign: TextAlign.start)
//                             : const SizedBox.shrink(),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         Wrap(
//                           crossAxisAlignment: WrapCrossAlignment.end,
//                           alignment: WrapAlignment.start,
//                           direction: Axis.horizontal,
//                           spacing: 8,
//                           runSpacing: 8, //0
//                           children: [
//                             if (animeData.score != null &&
//                                 animeData.score != '0.0')
//                               Chip(
//                                 avatar: const Icon(Icons.star),
//                                 padding: const EdgeInsets.all(0),
//                                 shadowColor: Colors.transparent,
//                                 elevation: 0,
//                                 side: const BorderSide(
//                                     width: 0, color: Colors.transparent),
//                                 labelStyle: context.theme.textTheme.bodyMedium
//                                     ?.copyWith(
//                                         color: context.theme.colorScheme
//                                             .onSecondaryContainer),
//                                 backgroundColor: context
//                                     .theme.colorScheme.secondaryContainer,
//                                 label: Text(animeData.score ?? '0'),
//                               ),
//                             if (titleInfo.rating != '?')
//                               Chip(
//                                 //avatar: const Icon(Icons.star),
//                                 padding: const EdgeInsets.all(0),
//                                 shadowColor: Colors.transparent,
//                                 elevation: 0,
//                                 side: const BorderSide(
//                                     width: 0, color: Colors.transparent),
//                                 labelStyle: context.theme.textTheme.bodyMedium
//                                     ?.copyWith(
//                                         color: context.theme.colorScheme
//                                             .onSecondaryContainer),
//                                 backgroundColor: context
//                                     .theme.colorScheme.secondaryContainer,
//                                 label: Text(titleInfo.rating),
//                               ),
//                             if (titleInfo.title.asData?.value.genres !=
//                                 null) ...[
//                               ...List.generate(
//                                 titleInfo.title.asData!.value.genres!.length,
//                                 (index) => GestureDetector(
//                                   onTap: () {
//                                     context.pushNamed('explore_search');
//                                   },
//                                   child: Chip(
//                                     padding: const EdgeInsets.all(0),
//                                     shadowColor: Colors.transparent,
//                                     elevation: 0,
//                                     side: const BorderSide(
//                                         width: 0, color: Colors.transparent),
//                                     labelStyle: context
//                                         .theme.textTheme.bodyMedium
//                                         ?.copyWith(
//                                             color: context.theme.colorScheme
//                                                 .onSecondaryContainer),
//                                     backgroundColor: context
//                                         .theme.colorScheme.secondaryContainer,
//                                     label: Text(titleInfo.title.asData!.value
//                                             .genres![index].russian ??
//                                         ""),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                             if (titleInfo.title.asData?.value.studios !=
//                                 null) ...[
//                               ...List.generate(
//                                 titleInfo.title.asData!.value.studios!.length,
//                                 (index) => Chip(
//                                   padding: const EdgeInsets.all(0),
//                                   shadowColor: Colors.transparent,
//                                   elevation: 0,
//                                   side: const BorderSide(
//                                       width: 0, color: Colors.transparent),
//                                   labelStyle: context.theme.textTheme.bodyMedium
//                                       ?.copyWith(
//                                           color: context.theme.colorScheme
//                                               .onSecondaryContainer),
//                                   backgroundColor: context
//                                       .theme.colorScheme.secondaryContainer,
//                                   avatar: Padding(
//                                     padding:
//                                         const EdgeInsets.fromLTRB(4, 4, 0, 4),
//                                     child: CircleAvatar(
//                                       backgroundColor: context
//                                           .theme.colorScheme.secondaryContainer,

//                                       backgroundImage:
//                                           CachedNetworkImageProvider(
//                                         '${AppConfig.staticUrl}${titleInfo.title.asData!.value.studios![index].image ?? '/assets/globals/missing/mini.png'}',
//                                         cacheManager: cacheManager,
//                                       ),

//                                       //     ExtendedNetworkImageProvider(
//                                       //   '${AppConfig.staticUrl}${titleInfo.title.asData!.value.studios![index].image ?? '/assets/globals/missing/mini.png'}',
//                                       //   cache: true,
//                                       // ),
//                                     ),
//                                   ),
//                                   label: Text(titleInfo.title.asData!.value
//                                           .studios![index].name ??
//                                       ""),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                         if (titleInfo.title.asData?.value.description !=
//                             null) ...[
//                           const SizedBox(
//                             height: 8,
//                           ),
//                           TitleDescription(
//                             titleInfo.title.asData!.value.descriptionHtml ??
//                                 titleInfo.title.asData!.value.description!,
//                           ),
//                         ],
//                         if (titleInfo.title.asData?.value.description == null &&
//                             !titleInfo.title.isLoading) ...[
//                           const SizedBox(
//                             height: 8,
//                           ),
//                           Text(
//                             'Описание отсутствует.',
//                             style:
//                                 Theme.of(context).textTheme.bodyLarge!.copyWith(
//                                       //fontSize: 15,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 16,
//               ),
//               ...titleInfo.title.when(
//                 data: (data) => [
//                   AnimeActionsWidget(
//                     anime: data,
//                   ),
//                   const SizedBox(
//                     height: 16,
//                   ),
//                   if (data.screenshots != null || data.videos != null)
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (data.screenshots != null &&
//                             data.screenshots!.isNotEmpty) ...[
//                           Expanded(
//                             flex: 1,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Card(
//                                   margin: const EdgeInsets.all(0),
//                                   clipBehavior: Clip.antiAlias,
//                                   elevation: 4,
//                                   child: Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Text(
//                                           'Кадры',
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyLarge!
//                                               .copyWith(
//                                                   fontWeight: FontWeight.bold),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 8,
//                                 ),
//                                 AnimeScreenshotsWidget(
//                                   screenshots: data.screenshots,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           if (data.videos != null && data.videos!.isNotEmpty)
//                             const SizedBox(
//                               width: 16,
//                             ),
//                         ],
//                         if (data.videos != null && data.videos!.isNotEmpty) ...[
//                           Expanded(
//                             flex: 1,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Card(
//                                   margin: const EdgeInsets.all(0),
//                                   clipBehavior: Clip.antiAlias,
//                                   elevation: 4,
//                                   child: Row(
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Text(
//                                           'Видео',
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyLarge!
//                                               .copyWith(
//                                                   fontWeight: FontWeight.bold),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 8,
//                                 ),
//                                 AnimeVideosWidget(
//                                   videos: data.videos,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   if (titleInfo.statsValues != []) ...[
//                     const SizedBox(
//                       height: 16,
//                     ),
//                     AnimeRatesStatusesWidget(
//                       statsValues: titleInfo.statsValues,
//                     ),
//                   ],
//                   const SizedBox(
//                     height: 16,
//                   ),
//                   // AnimeRelatedTitlesWidget(
//                   //   animeId: animeData.id!,
//                   // ),
//                   RelatedWidget(
//                     id: animeData.id!,
//                   ),
//                   const SizedBox(
//                     height: 70,
//                   ),
//                 ],
//                 loading: () => [
//                   const Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 ],
//                 error: (error, stackTrace) => [
//                   CustomErrorWidget(error.toString(),
//                       () => ref.refresh(titleInfoPageProvider(animeData.id!))),
//                 ],
//               ),

//               // const SizedBox(
//               //   height: 216,
//               // ),
//               // Row(
//               //   crossAxisAlignment: CrossAxisAlignment.start,
//               //   children: [
//               //     Expanded(
//               //       flex: 1,
//               //       child: Container(
//               //         color: Colors.deepOrange,
//               //         child: const Text('Кадры'),
//               //       ),
//               //     ),
//               //     const SizedBox(
//               //       width: 8,
//               //     ),
//               //     Expanded(
//               //       flex: 1,
//               //       child: Container(
//               //         color: Colors.deepPurple,
//               //         child: const Text('Видео'),
//               //       ),
//               //     ),
//               //     const SizedBox(
//               //       width: 8,
//               //     ),
//               //     Expanded(
//               //       flex: 2,
//               //       child: Container(
//               //         color: Colors.pink,
//               //         child: const Text('Видео'),
//               //       ),
//               //     )
//               //   ],
//               // ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: titleInfo.title.isLoading //titleInfo.isAnons
//           ? null
//           : FloatingActionButton.extended(
//               onPressed: () async {
//                 if (titleInfo.rating == '18+') {
//                   final allowExp = ref
//                           .read(preferencesProvider)
//                           .sharedPreferences
//                           .getBool('allowExpContent') ??
//                       false;

//                   if (!allowExp) {
//                     bool? dialogValue = await showDialog<bool>(
//                       barrierDismissible: false,
//                       context: context,
//                       builder: (context) => const RatingDialog(),
//                     );

//                     if (dialogValue ?? false) {
//                       await ref
//                           .read(preferencesProvider)
//                           .sharedPreferences
//                           .setBool('allowExpContent', true);
//                       // ignore: use_build_context_synchronously
//                       pushStudioSelectPage(
//                         ctx: context,
//                         id: animeData.id ?? 0,
//                         name: animeData.russian ??
//                             animeData.name ??
//                             '[Без навзвания]',
//                         ep: titleInfo.currentProgress,
//                         imgUrl: animeData.image?.original ?? '',
//                       );
//                     }
//                   } else {
//                     pushStudioSelectPage(
//                       ctx: context,
//                       id: animeData.id ?? 0,
//                       name: animeData.russian ??
//                           animeData.name ??
//                           '[Без навзвания]',
//                       ep: titleInfo.currentProgress,
//                       imgUrl: animeData.image?.original ?? '',
//                     );
//                   }
//                 } else {
//                   pushStudioSelectPage(
//                     ctx: context,
//                     id: animeData.id ?? 0,
//                     name: animeData.russian ??
//                         animeData.name ??
//                         '[Без навзвания]',
//                     ep: titleInfo.currentProgress,
//                     imgUrl: animeData.image?.original ?? '',
//                   );
//                 }
//               },
//               label: const Text('Смотреть'),
//               icon: const Icon(Icons.play_arrow),
//             ),
//     );
//   }

//   void pushStudioSelectPage({
//     required BuildContext ctx,
//     required int id,
//     required String name,
//     required int ep,
//     required String imgUrl,
//   }) {
//     // Navigator.push(
//     //   ctx,
//     //   PageRouteBuilder(
//     //     pageBuilder: (context, animation1, animation2) => StudioSelectPage(
//     //       //animeId: titleInfo.id,
//     //       shikimoriId: id,
//     //       animeName: name,
//     //       searchName: '',
//     //       epWatched: ep,
//     //       imageUrl: imgUrl,
//     //     ),
//     //     transitionDuration: Duration.zero,
//     //     reverseTransitionDuration: Duration.zero,
//     //   ),
//     // );
//   }
// }

// class AnimeScreenshotsWidget extends StatelessWidget {
//   final List<Screenshots>? screenshots;
//   const AnimeScreenshotsWidget({super.key, required this.screenshots});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         ...List.generate(
//           screenshots!.length,
//           (index) {
//             return Expanded(
//               flex: 1,
//               child: Padding(
//                 padding: index == 1
//                     ? const EdgeInsets.fromLTRB(4, 0, 0, 0)
//                     : const EdgeInsets.fromLTRB(0, 0, 4, 0),
//                 child: AspectRatio(
//                   aspectRatio: 16 / 9,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: ImageWithShimmerWidget(
//                       imageUrl: AppConfig.staticUrl +
//                           (screenshots![index].original ??
//                               screenshots![index].preview ??
//                               ''),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

// class AnimeVideosWidget extends StatelessWidget {
//   final List<Videos>? videos;
//   const AnimeVideosWidget({super.key, required this.videos});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         ...List.generate(
//           videos!.length,
//           (index) {
//             return Expanded(
//               flex: 1,
//               child: Padding(
//                 padding: index == 1
//                     ? const EdgeInsets.fromLTRB(4, 0, 0, 0)
//                     : const EdgeInsets.fromLTRB(0, 0, 4, 0),
//                 child: ClipRRect(
//                   clipBehavior: Clip.hardEdge,
//                   borderRadius: BorderRadius.circular(12),
//                   child: InkWell(
//                     onTap: () => launchUrlString(videos![index].url ?? ''),
//                     child: Stack(
//                       //alignment: Alignment.bottomCenter,
//                       children: [
//                         AspectRatio(
//                           aspectRatio: 16 / 9,
//                           child: ImageWithShimmerWidget(
//                             imageUrl: videos![index].imageUrl ?? '',
//                           ),
//                         ),
//                         Positioned(
//                           left: -1, //0
//                           right: -1, //0
//                           top: 40,
//                           bottom: -1,
//                           child: Container(
//                             clipBehavior: Clip.hardEdge,
//                             padding: const EdgeInsets.all(6.0),
//                             alignment: Alignment.bottomCenter,
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                                 colors: <Color>[
//                                   Colors.black.withAlpha(0),
//                                   Colors.black54,
//                                   Colors.black87,
//                                 ],
//                               ),
//                             ),
//                             child: Text(
//                               //'Тизер',
//                               videos![index].name ?? videos![index].kind ?? '',
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
