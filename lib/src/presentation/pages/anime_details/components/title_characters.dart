import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/config.dart';
import '../../../../domain/models/shiki_role.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/anime_details_provider.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/custom_shimmer.dart';

class TitleCharactersWidget extends ConsumerWidget {
  final int id;
  const TitleCharactersWidget(this.id, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(rolesAnimeProvider(id));

    return roles.when(
      data: (data) {
        if (data.isEmpty) {
          return const SizedBox.shrink();
        }

        final characters =
            data.where((e) => e.character != null && e.person == null).toList();

        //final characters = data.where((e) => e.roles?.first == 'Main').toList();

        if (characters.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 4.0),
                      child: Text(
                        'Персонажи',
                        style: context.textTheme.bodyLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '(${characters.length})',
                      //style: context.textTheme.bodySmall,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colorScheme.onBackground.withOpacity(
                          0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 120, //210
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: characters.length,
                  // separatorBuilder: (context, index) =>
                  //     const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isFirstItem = index == 0;
                    final item = characters[index];

                    return Container(
                      margin:
                          EdgeInsets.fromLTRB(isFirstItem ? 16 : 0, 0, 8, 0),
                      height: 120,
                      child: CharacterCard(item.character!),
                    );

                    // return AspectRatio(
                    //   aspectRatio: 0.55,
                    //   child: CharacterCard(item.character!),
                    // );
                  },
                ),
              ),
            ],
          ).animate().fadeIn(),
        );
      },
      error: (e, _) => const SizedBox.shrink(),
      loading: () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Персонажи',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 120, //160
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return const AspectRatio(
                    aspectRatio: 1.0,
                    child: ClipOval(
                      child: CustomShimmer(),
                    ),
                  );

                  // return AspectRatio(
                  //   aspectRatio: 0.708,
                  //   child: ClipRRect(
                  //     borderRadius: BorderRadius.circular(12),
                  //     child: const CustomShimmer(),
                  //   ),
                  // );
                },
              ),
            ),
          ],
        ).animate().fadeIn(),
      ),
    );
  }
}

class CharacterCard extends StatelessWidget {
  final ShikiRoleItem character;

  const CharacterCard(this.character, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12.0),
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => context.pushNamed(
          'character',
          pathParameters: <String, String>{
            'id': (character.id!).toString(),
          },
        ),
        child: Column(
          children: [
            CachedCircleImage(
              AppConfig.staticUrl + (character.image?.original ?? ''),
              radius: 48,
            ),
            LimitedBox(
              maxWidth: 100,
              child: Text(
                character.name ?? '[Без имени]',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    // return LayoutBuilder(
    //   builder: (context, constraints) {
    //     return InkWell(
    //       splashColor: Colors.transparent,
    //       highlightColor: Colors.transparent,
    //       splashFactory: NoSplash.splashFactory,
    //       onTap: () => context.pushNamed(
    //         'character',
    //         pathParameters: <String, String>{
    //           'id': (character.id!).toString(),
    //         },
    //       ),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           SizedBox(
    //             width: constraints.maxWidth,
    //             height: constraints.maxHeight / 1.3,
    //             child: ClipRRect(
    //               borderRadius: BorderRadius.circular(12.0),
    //               child: ImageWithShimmerWidget(
    //                 imageUrl:
    //                     AppConfig.staticUrl + (character.image?.original ?? ''),
    //               ),
    //             ),
    //           ),
    //           const SizedBox(
    //             height: 4,
    //           ),
    //           Flexible(
    //             child: Text(
    //               (character.russian == ''
    //                       ? character.name
    //                       : character.russian) ??
    //                   '',
    //               maxLines: 2,
    //               overflow: TextOverflow.ellipsis,
    //               style: const TextStyle(
    //                 fontSize: 14.0,
    //                 height: 1.2,
    //                 //fontWeight: FontWeight.w500,
    //               ),
    //             ),
    //           )
    //         ],
    //       ),
    //     );
    //   },
    // );
  }
}
