import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/cached_image.dart';
import '../graphql_character.dart';

const String shikiMissingImage =
    'https://shikimori.one/assets/globals/missing/main.png';

class TitleCharacters extends StatelessWidget {
  const TitleCharacters(this.characterRoles, {super.key});

  final List<CharacterRole> characterRoles;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          // ListTile(
          //   onTap: () {},
          //   title: const Text('Персонажи'),
          //   trailing: const Icon(Icons.chevron_right_rounded),
          // ),
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
            height: 120, //210
            child: ListView.builder(
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
                  height: 120,
                  child: _CharacterCard(item.character),
                  //child: CharacterCard(item.character!),
                );
              },
            ),
          ),
        ].animate().fade(),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard(this.character);

  final Character character;

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
            'id': (character.id).toString(),
          },
        ),
        child: Column(
          children: [
            CachedCircleImage(
              character.poster ?? shikiMissingImage,
              radius: 48,
              clipBehavior: Clip.antiAlias,
              memCacheHeight: 200,
            ),
            LimitedBox(
              maxWidth: 100,
              child: Text(
                character.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
