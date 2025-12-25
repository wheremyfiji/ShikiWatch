import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:go_router/go_router.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/custom_radius_animator.dart';
import '../graphql_character.dart';

const String shikiMissingImage =
    'https://shikimori.one/assets/globals/missing/main.png';

class TitleCharacters extends StatelessWidget {
  const TitleCharacters(this.characterRoles, {super.key});

  final List<CharacterRole> characterRoles;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed(
        [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
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
                if (characterRoles.length > 6) ...[
                  const Spacer(),
                  IconButton(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => AllCharactersBottomSheet.show(
                        context: context, characters: characterRoles),
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                    ),
                  ),
                ]
              ],
            ),
          ),
          SizedBox(
            height: 164, //120
            child: ListView.builder(
              itemExtentBuilder: (index, dimensions) {
                final isFirstItem = index == 0;
                final isLast = index == characterRoles.length - 1;

                return 100 + (isFirstItem ? 16 : 0) + (isLast ? 16 : 8);
              },
              scrollDirection: Axis.horizontal,
              itemCount: characterRoles.length,
              itemBuilder: (context, index) {
                final item = characterRoles[index];
                final isFirstItem = index == 0;
                final isLast = index == characterRoles.length - 1;

                return Container(
                  margin: EdgeInsets.only(
                    left: isFirstItem ? 16 : 0,
                    right: isLast ? 16 : 8,
                  ),
                  child: _CharacterCard(item.character),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterCard extends HookWidget {
  const _CharacterCard(this.character);

  final Character character;

  static const _defaultRadius = 64.0;

  @override
  Widget build(BuildContext context) {
    final targetRadius = useState(_defaultRadius);

    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomRadiusAnimator(
              targetRadius: targetRadius.value,
              builder: (context, r) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(r),
                  child: Stack(
                    children: [
                      CachedImage(
                        character.poster ?? shikiMissingImage,
                        width: 100,
                      ),
                      Align(
                        child: SizedBox(
                          width: 100,
                          child: Material(
                            type: MaterialType.transparency,
                            child: GestureDetector(
                              onLongPressStart: (_) {
                                targetRadius.value = 24.0;
                              },
                              onLongPressEnd: (_) {
                                targetRadius.value = _defaultRadius;
                              },
                              child: InkWell(
                                onHover: (isHovering) {
                                  targetRadius.value =
                                      isHovering ? 24.0 : _defaultRadius;
                                },
                                onTap: () => context.pushNamed(
                                  'character',
                                  pathParameters: <String, String>{
                                    'id': (character.id).toString(),
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ),
        LimitedBox(
          maxWidth: 100,
          child: Text(
            character.russian ?? character.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// class _CharacterCard extends StatelessWidget {
//   const _CharacterCard(this.character);

//   final Character character;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       borderRadius: BorderRadius.circular(12.0),
//       color: Colors.transparent,
//       clipBehavior: Clip.hardEdge,
//       child: InkWell(
//         onTap: () => context.pushNamed(
//           'character',
//           pathParameters: <String, String>{
//             'id': (character.id).toString(),
//           },
//         ),
//         child: Column(
//           children: [
//             CachedCircleImage(
//               character.poster ?? shikiMissingImage,
//               radius: 48,
//               clipBehavior: Clip.antiAlias,
//               memCacheHeight: 200,
//             ),
//             LimitedBox(
//               maxWidth: 100,
//               child: Text(
//                 character.name,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class AllCharactersBottomSheet extends StatelessWidget {
  final List<CharacterRole> characters;

  const AllCharactersBottomSheet(this.characters, {super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      minChildSize: 0.5,
      initialChildSize: 0.75,
      snapSizes: const [0.75, 1.0],
      builder: (context, scrollController) {
        return SafeArea(
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    'Все персонажи',
                    style: context.textTheme.titleLarge,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Divider(height: 1),
              ),
              SliverList.builder(
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index].character;

                  return ListTile(
                    onTap: () {
                      //Navigator.of(context).pop();
                      context.pushNamed(
                        'character',
                        pathParameters: <String, String>{
                          'id': (character.id).toString(),
                        },
                      );
                    },
                    leading: CachedCircleImage(
                      character.poster ?? shikiMissingImage,
                    ),
                    title: Text(character.name),
                    subtitle: character.russian == null
                        ? null
                        : Text(character.russian!),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void show(
      {required BuildContext context,
      required List<CharacterRole> characters}) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      useRootNavigator: false,
      showDragHandle: true,
      backgroundColor: context.colorScheme.background,
      elevation: 0,
      builder: (_) => SafeArea(child: AllCharactersBottomSheet(characters)),
    );
  }
}
