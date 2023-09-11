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

class AnimeCharactersWidget extends ConsumerWidget {
  final int id;

  const AnimeCharactersWidget(this.id, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(animeRolesProvider(id));

    return TitleCharactersWidget(roles);
  }
}

class TitleCharactersWidget extends StatelessWidget {
  final AsyncValue<List<ShikiRole>> roles;

  const TitleCharactersWidget(this.roles, {super.key});

  @override
  Widget build(BuildContext context) {
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
                    if (characters.length > 2) ...[
                      const Spacer(),
                      IconButton(
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => AllCharactersBottomSheet.show(
                            context: context, characters: characters),
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
  }
}

class AllCharactersBottomSheet extends StatelessWidget {
  final List<ShikiRole> characters;

  const AllCharactersBottomSheet(this.characters, {super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      minChildSize: 0.5,
      initialChildSize: 0.75,
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
                  final chara = characters[index];

                  return ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      context.pushNamed(
                        'character',
                        pathParameters: <String, String>{
                          'id': (chara.character!.id!).toString(),
                        },
                      );
                    },
                    leading: CachedCircleImage(
                      AppConfig.staticUrl +
                          (chara.character!.image?.original ?? ''),
                    ),
                    title: Text(chara.character!.name ?? '[Без имени]'),
                    subtitle: chara.character!.russian == null
                        ? null
                        : Text(chara.character!.russian ?? ''),
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
      {required BuildContext context, required List<ShikiRole> characters}) {
    showModalBottomSheet(
      context: context,
      useSafeArea: false,
      isScrollControlled: true,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (_) => SafeArea(child: AllCharactersBottomSheet(characters)),
    );
  }
}
