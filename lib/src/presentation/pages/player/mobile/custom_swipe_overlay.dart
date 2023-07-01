// import 'package:flutter/material.dart';

// import 'package:double_tap_player_view/double_tap_player_view.dart';

// class CustomSwipeOverlay extends StatelessWidget {
//   final SwipeData data;
//   final Duration currentPos;

//   const CustomSwipeOverlay({
//     super.key,
//     required this.data,
//     required this.currentPos,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final dxDiff = (data.currentDx - data.startDx).toInt();
//     final diffDuration = Duration(seconds: dxDiff);
//     final prefix = diffDuration.isNegative ? '-' : '+';
//     final positionText = '$prefix${diffDuration.printDuration()}';
//     final aimedDuration = diffDuration + currentPos;
//     final diffText = aimedDuration.printDuration();

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             positionText,
//             style: const TextStyle(
//               fontSize: 30,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             diffText,
//             style: const TextStyle(
//               fontSize: 20,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// extension on Duration {
//   /// ref: https://stackoverflow.com/a/54775297/8183034
//   String printDuration() {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final twoDigitMinutes = twoDigits(inMinutes.abs().remainder(60));
//     final twoDigitSeconds = twoDigits(inSeconds.abs().remainder(60));
//     return '$twoDigitMinutes:$twoDigitSeconds';
//   }
// }
