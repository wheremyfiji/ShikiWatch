import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../services/updater/update_service.dart';

class OtherMoreActions extends StatelessWidget {
  const OtherMoreActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // const SizedBox(
          //   height: 16,
          // ),
          // Row(
          //   children: [
          //     Expanded(
          //       child: TextField(
          //         readOnly: true,
          //         controller: TextEditingController(text: '777'),
          //         decoration: const InputDecoration(
          //           contentPadding: EdgeInsets.zero,
          //           border: InputBorder.none,
          //           filled: false,
          //           labelText: 'Эпизоды',
          //           hintText: 'Эпизоды',
          //           prefixIcon: Padding(
          //             padding: EdgeInsets.only(left: 8),
          //             child: Icon(Icons.add_circle_outline_rounded),
          //           ),
          //           suffixText: '/1002',
          //         ),
          //       ),
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(left: 24, right: 8),
          //       child: IconButton.outlined(
          //         style:
          //             const ButtonStyle(visualDensity: VisualDensity.compact),
          //         onPressed: () {},
          //         icon: const Icon(Icons.exposure_minus_1_rounded),
          //       ),
          //     ),
          //     const Padding(
          //       padding: EdgeInsets.only(left: 0, right: 16),
          //       child: IconButton.filled(
          //         style: ButtonStyle(visualDensity: VisualDensity.compact),
          //         onPressed: null,
          //         icon: Icon(Icons.plus_one_rounded),
          //       ),
          //     ),
          //   ],
          // ),
          ListTile(
            onTap: () => context.pushNamed('profile_settings'),
            title: const Text('Настройки'),
            leading: const Icon(Icons.settings),
          ),
          ListTile(
            onTap: () => context.pushNamed('about'),
            leading: const Icon(Icons.info),
            title: const Text('О приложении'),
            trailing: Consumer(
              builder: (context, ref, child) {
                final release = ref.watch(appReleaseProvider);

                return release.when(
                  data: (data) {
                    if (data == null) {
                      return const SizedBox.shrink();
                    }

                    return Badge.count(
                      count: 1,
                    );
                  },
                  error: (_, __) => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
