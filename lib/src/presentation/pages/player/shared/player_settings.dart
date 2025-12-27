import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../utils/app_utils.dart';
import '../shaders_provider.dart';

class ShaderSelectorWidget extends ConsumerWidget {
  const ShaderSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeShaders = ref.watch(activeShadersProvider);
    final notifier = ref.read(activeShadersProvider.notifier);
    final availableShaders = ref.watch(availableShadersProvider);

    final exclusive = availableShaders.where((e) => e.isExclusive).toList();
    final nonExclusive = availableShaders.where((e) => !e.isExclusive).toList();

    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      minChildSize: 0.25,
      initialChildSize: AppUtils.instance.isDesktop ? 0.5 : 0.75,
      snapSizes: const [0.5, 0.75, 1.0],
      builder: (context, scrollController) {
        return SafeArea(
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Card(
                  // elevation: 0,
                  // color: context.colorScheme.primaryContainer,
                  // shadowColor: Colors.transparent,
                  // surfaceTintColor: Colors.transparent,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: ListTile(
                    title: Text(
                      // activeShaders.isNotEmpty
                      //     ? 'Шейдеры (${activeShaders.length})'
                      //     :
                      'Шейдеры',
                      // style: context.textTheme.titleLarge,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    subtitle: Text(
                      // 'При использовании возможны проблемы с воспроизведением.\nОбычные шейдеры можно наслаивать друг на друга в порядке выбора.',
                      'При использовании возможны проблемы с воспроизведением',
                      style: context.textTheme.bodySmall?.copyWith(
                        // color: context.colorScheme.onSurfaceVariant,
                        color: context.colorScheme.onPrimaryContainer
                            .withOpacity(0.8),
                      ),
                    ),
                    trailing: activeShaders.isNotEmpty
                        ? TextButton(
                            onPressed: () => notifier.clearAll(),
                            // onPressed: () {},
                            child: const Text('Сбросить'),
                          )
                        : null,
                  ),
                ),
              ),
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Expanded(
              //           child: Column(
              //             mainAxisSize: MainAxisSize.min,
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text('Шейдеры (${activeShaders.length})',
              //                   style:
              //                       Theme.of(context).textTheme.headlineSmall),
              //               Text(
              //                 'При использовании возможны проблемы с воспроизведением.\nНекоторые шейдеры можно наслаивать друг на друга.',
              //                 style: TextStyle(
              //                   fontSize: 12,
              //                   color: context.colorScheme.onSurfaceVariant,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //         if (activeShaders.isNotEmpty)
              //           TextButton(
              //             // onPressed: () => notifier.clearAll(),
              //             onPressed: () {},
              //             child: const Text('Сбросить'),
              //           ),
              //       ],
              //     ),
              //   ),
              // ),
              // const SliverToBoxAdapter(
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 16.0),
              //     child: Divider(),
              //   ),
              // ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Text('Обычные шейдеры'),
                      SizedBox(width: 12.0),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: nonExclusive.length,
                itemBuilder: (context, index) {
                  final shader = nonExclusive[index];
                  final isActive = activeShaders.contains(shader);
                  final orderIndex = activeShaders.indexOf(shader) + 1;

                  final leading = isActive
                      ? (shader.isExclusive
                          ? const SizedBox.square(
                              dimension: 24.0,
                              child: Center(
                                child: Icon(
                                  Icons.lock_rounded,
                                  size: 20.0,
                                ),
                              ),
                            )
                          : SizedBox.square(
                              dimension: 24.0,
                              child: Center(
                                child: CircleAvatar(
                                  backgroundColor:
                                      context.colorScheme.primaryContainer,
                                  child: Text(
                                    '$orderIndex',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: context
                                          .colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                      : const SizedBox.square(
                          dimension: 24.0,
                          child: Center(
                            child: Icon(
                              Icons.circle_outlined,
                              size: 20.0,
                            ),
                          ),
                        );

                  return ListTile(
                    leading: leading,
                    title: Text(
                      shader.name,
                      style: TextStyle(
                        color: isActive
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurface,
                        fontWeight:
                            isActive ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                    subtitle: shader.description == null
                        ? null
                        : Text(
                            shader.description!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                    onTap: () => notifier.toggle(shader),
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text('Одиночные шейдеры'),
                      SizedBox(width: 12.0),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: exclusive.length,
                itemBuilder: (context, index) {
                  final shader = exclusive[index];
                  final isActive = activeShaders.contains(shader);
                  final orderIndex = activeShaders.indexOf(shader) + 1;

                  final leading = isActive
                      ? (shader.isExclusive
                          ? const SizedBox.square(
                              dimension: 24.0,
                              child: Center(
                                child: Icon(
                                  Icons.lock_rounded,
                                  size: 20.0,
                                ),
                              ),
                            )
                          : SizedBox.square(
                              dimension: 24.0,
                              child: Center(
                                child: CircleAvatar(
                                  backgroundColor:
                                      context.colorScheme.primaryContainer,
                                  child: Text(
                                    '$orderIndex',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: context
                                          .colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                      : const SizedBox.square(
                          dimension: 24.0,
                          child: Center(
                            child: Icon(
                              Icons.circle_outlined,
                              size: 20.0,
                            ),
                          ),
                        );

                  return ListTile(
                    leading: leading,
                    title: Text(
                      shader.name,
                      style: TextStyle(
                        color: isActive
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurface,
                        fontWeight:
                            isActive ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                    subtitle: shader.description == null
                        ? null
                        : Text(
                            shader.description!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                    onTap: () => notifier.toggle(shader),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      useRootNavigator: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
      ),
      elevation: 0,
      backgroundColor: context.colorScheme.background,
      builder: (ctx) {
        return const ShaderSelectorWidget();
      },
    );
  }
}
