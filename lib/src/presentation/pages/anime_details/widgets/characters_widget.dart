import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/config.dart';
import '../../../../domain/models/shiki_role.dart';
import '../../../providers/anime_details_provider.dart';
import '../../../widgets/custom_shimmer.dart';
import '../../../widgets/image_with_shimmer.dart';

class CharactersWidget extends ConsumerWidget {
  final int id;
  const CharactersWidget(this.id, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(rolesAnimeProvider(id));

    return roles.when(
      data: (data) {
        if (data.isEmpty) {
          return const SizedBox.shrink();
        }

        final characters = data.where((e) => e.roles?.first == 'Main').toList();

        if (characters.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Главные герои',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: characters.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = characters[index];

                    return AspectRatio(
                      aspectRatio: 0.55,
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
                'Главные герои',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return AspectRatio(
                    aspectRatio: 0.708,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: const CustomShimmer(),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          onTap: () => context.pushNamed(
            'character',
            pathParameters: <String, String>{
              'id': (character.id!).toString(),
            },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight / 1.3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: ImageWithShimmerWidget(
                    imageUrl:
                        AppConfig.staticUrl + (character.image?.original ?? ''),
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Flexible(
                child: Text(
                  (character.russian == ''
                          ? character.name
                          : character.russian) ??
                      '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.0,
                    height: 1.2,
                    //fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
