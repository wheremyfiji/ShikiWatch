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
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: ListTile(
                    title: Text(
                      'Шейдеры',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    subtitle: Text(
                      'При использовании возможны проблемы с воспроизведением',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onPrimaryContainer
                            .withOpacity(0.8),
                      ),
                    ),
                    trailing: activeShaders.isNotEmpty
                        ? TextButton(
                            onPressed: () => notifier.clearAll(),
                            child: const Text('Сбросить'),
                          )
                        : null,
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(top: 12)),
              const TextWithDivider(label: 'Обычные шейдеры'),
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
              const TextWithDivider(label: 'Одиночные шейдеры'),
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

class TextWithDivider extends StatelessWidget {
  const TextWithDivider({
    super.key,
    required this.label,
    this.style,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.space = 12.0,
  });

  final String label;
  final double space;
  final EdgeInsetsGeometry padding;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            Text(label, style: style),
            SizedBox(width: space),
            const Expanded(child: Divider()),
          ],
        ),
      ),
    );
  }
}
