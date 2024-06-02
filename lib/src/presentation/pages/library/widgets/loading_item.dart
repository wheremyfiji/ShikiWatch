import 'package:flutter/material.dart';

import '../../../../domain/enums/library_layout_mode.dart';
import '../../../widgets/loading_grid.dart';

class LibraryLoadingItem extends StatelessWidget {
  const LibraryLoadingItem(this.currentLayout, {super.key});

  final LibraryLayoutMode currentLayout;

  @override
  Widget build(BuildContext context) {
    return switch (currentLayout) {
      LibraryLayoutMode.compactList => const Center(
          child: CircularProgressIndicator(),
        ),
      // const _LoadingCompactList(),
      LibraryLayoutMode.list => const Center(
          child: CircularProgressIndicator(),
        ),
      //const LoadingList(),
      LibraryLayoutMode.grid => const LoadingGrid(),
    };
  }
}

// class _LoadingCompactList extends StatelessWidget {
//   const _LoadingCompactList();

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         SliverList.builder(
//           itemCount: 12,
//           itemBuilder: (context, index) {
//             return ListTile(
//               visualDensity: VisualDensity.compact,
//               leading: SizedBox(
//                 height: 48,
//                 child: AspectRatio(
//                   aspectRatio: 1,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8.0),
//                     child: const CustomShimmer(),
//                   ),
//                 ),
//               ),
//               title: SizedBox(
//                 height: 8,
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: 4,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(6.0),
//                         child: const CustomShimmer(),
//                       ),
//                     ),
//                     const Expanded(
//                       flex: 1,
//                       child: SizedBox.shrink(),
//                     ),
//                   ],
//                 ),
//               ),
//               subtitle: SizedBox(
//                 height: 6,
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: 3,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(3.0),
//                         child: const CustomShimmer(),
//                       ),
//                     ),
//                     const Expanded(
//                       flex: 4,
//                       child: SizedBox.shrink(),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
