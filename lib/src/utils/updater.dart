// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// import 'package:http/http.dart' as http;
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import 'package:version/version.dart';

// import 'target_platform.dart';

// class Update {
//   final String? version;
//   final bool? critical;
//   final String? description;
//   final String? url;

//   Update({
//     required this.version,
//     required this.critical,
//     required this.description,
//     required this.url,
//   });

//   Update.fromJson(Map<String, dynamic> json)
//       : version = json['version'],
//         critical = json['critical'],
//         description = json['description'],
//         url = json['url'];
// }

// class UpdaterWidget extends StatefulWidget {
//   final Widget child;
//   const UpdaterWidget({super.key, required this.child});

//   @override
//   State<UpdaterWidget> createState() => _UpdaterWidgetState();
// }

// class _UpdaterWidgetState extends State<UpdaterWidget> {
//   bool d = false;

//   checkLatestVersion() async {
//     if (kDebugMode) {
//       return;
//     }

//     if (TargetP.instance.isDesktop) {
//       return;
//     }

//     if (d) {
//       return;
//     }

//     final response = await http.get(Uri.parse(
//         'https://raw.githubusercontent.com/wheremyfiji/ShikiWatch/master/updater.json'));

//     if (response.statusCode != 200) {
//       return;
//     }

//     final json = jsonDecode(utf8.decode(response.bodyBytes));

//     final result = [for (final e in json) Update.fromJson(e)];

//     final latest = result[0];

//     PackageInfo packageInfo = await PackageInfo.fromPlatform();

//     Version currentVersion = Version.parse(packageInfo.version);
//     Version latestVersion = Version.parse(latest.version!);

//     final crit = latest.critical!;
//     final url = latest.url;

//     if (latestVersion > currentVersion && crit && !d) {
//       _showCriticalDialog(
//         content: latest.description!,
//         url: url,
//       );

//       return;
//     }

//     if (latestVersion > currentVersion && !d) {
//       _showNormalDialog(
//         content: latest.description!,
//         currVer: currentVersion.toString(),
//         newVer: latestVersion.toString(),
//         url: url,
//       );
//     }
//   }

//   _showNormalDialog({
//     required String content,
//     required String? currVer,
//     required String? newVer,
//     String? url,
//   }) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           scrollable: true,
//           title: const Text('Доступно обновление'),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Текущая версия: $currVer'),
//               const SizedBox(
//                 height: 2,
//               ),
//               Text('Новая версия: $newVer'),
//               const SizedBox(
//                 height: 8,
//               ),
//               const Text(
//                 'Что нового',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(
//                 height: 4,
//               ),
//               Text(content),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Позже'),
//             ),
//             FilledButton(
//               onPressed: () {
//                 launchUrlString(
//                   url ??
//                       'https://github.com/wheremyfiji/ShikiWatch/releases/latest',
//                   mode: LaunchMode.externalApplication,
//                 );
//               },
//               child: const Text('Обновить'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   _showCriticalDialog({required String content, String? url}) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async {
//             return false;
//           },
//           child: AlertDialog(
//             scrollable: true,
//             title: const Text('Критическое обновление'),
//             content: Text(content),
//             actions: [
//               FilledButton(
//                 onPressed: () {
//                   launchUrlString(
//                     url ??
//                         'https://github.com/wheremyfiji/ShikiWatch/releases/latest',
//                     mode: LaunchMode.externalApplication,
//                   );
//                 },
//                 child: const Text('Обновить'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       checkLatestVersion();
//     });
//   }

//   @override
//   void dispose() {
//     d = true;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }
