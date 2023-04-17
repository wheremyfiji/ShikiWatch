import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import '../constants/box_types.dart';
import '../constants/hive_keys.dart';
import '../utils/router.dart';
import 'widgets/app_theme_builder.dart';
import 'widgets/shiki_annotate_region_widget.dart';

// const _appMainColor = Colors.orange;
// bool monetUI = true;

class ShikiApp extends StatelessWidget {
  const ShikiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShikiAnnotatedRegionWidget(
      child: ValueListenableBuilder<Box>(
        valueListenable: Hive.box(BoxType.settings.name).listenable(
          keys: [oledModeKey],
        ),
        builder: (context, value, child) {
          final bool isOled = value.get(oledModeKey, defaultValue: false);
          return AppThemeBuilder(
            builder: (context, appTheme) =>
                // MaterialApp(
                //   debugShowCheckedModeBanner: false,
                //   theme: appTheme.day,
                //   darkTheme: isOled ? appTheme.midnight : appTheme.night,
                //   title: 'Shiki!',
                //   themeMode: ThemeMode.system,
                //   home: const AnimeDetailsWindowsPage(),
                // ),
                MaterialApp.router(
              useInheritedMediaQuery: true,
              debugShowCheckedModeBanner: false,
              theme: appTheme.day,
              darkTheme: isOled ? appTheme.midnight : appTheme.night,
              title: 'Shiki!',
              themeMode: ThemeMode.system,
              routerConfig: router,
            ),
          );
        },
      ),
    );
    // return AppThemeBuilder(
    //   builder: (context, appTheme) => MaterialApp.router(
    //     useInheritedMediaQuery: true,
    //     debugShowCheckedModeBanner: false,
    //     theme: appTheme.day,
    //     //darkTheme: isMidnight ? appTheme.midnight : appTheme.night,
    //     darkTheme: appTheme.midnight,
    //     title: 'Shiki!',
    //     themeMode: ThemeMode.system,
    //     //themeMode: theme,
    //     routerConfig: router,
    //   ),
    // );
  }
}

// class ShikiApp extends StatelessWidget {
//   const ShikiApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // MediaQueryData windowData =
//     //     MediaQueryData.fromWindow(WidgetsBinding.instance.window);
//     // windowData = windowData.copyWith(
//     //     //textScaleFactor: 1.05,
//     //     //textScaleFactor: 1,
//     //     // windowData.textScaleFactor > 1.4 ? 1.4 : windowData.textScaleFactor,
//     //     );
//     return DynamicColorBuilder(
//       builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
//         ColorScheme lightColorScheme;
//         ColorScheme darkColorScheme;

//         if (lightDynamic != null && darkDynamic != null && monetUI) {
//           lightColorScheme = lightDynamic.harmonized();
//           darkColorScheme = darkDynamic.harmonized();
//         } else {
//           lightColorScheme = ColorScheme.fromSeed(
//             seedColor: _appMainColor,
//           );
//           darkColorScheme = ColorScheme.fromSeed(
//             seedColor: _appMainColor,
//             brightness: Brightness.dark,
//           );
//         }
//         return
//             //MediaQuery(
//             //  data: windowData,
//             //  child:
//             MaterialApp.router(
//           useInheritedMediaQuery: true,
//           //return MaterialApp(
//           title: 'Shiki!',
//           theme: ThemeData(
//             //fontFamily: 'SourceSansPro',
//             useMaterial3: true,
//             brightness: Brightness.light,
//             appBarTheme: appBarTheme(lightColorScheme),
//             tabBarTheme: tabBarTheme(lightColorScheme),
//             colorSchemeSeed: lightColorScheme.primary,
//             scaffoldBackgroundColor: lightColorScheme.background,
//             visualDensity: VisualDensity.adaptivePlatformDensity,
//           ),
//           darkTheme: ThemeData(
//             //fontFamily: 'SourceSansPro',
//             useMaterial3: true,
//             brightness: Brightness.dark,
//             appBarTheme: appBarTheme(darkColorScheme),
//             tabBarTheme: tabBarTheme(darkColorScheme),
//             colorSchemeSeed: darkColorScheme.primary,
//             scaffoldBackgroundColor: darkColorScheme.background,
//             visualDensity: VisualDensity.adaptivePlatformDensity,
//           ),
//           themeMode: ThemeMode.system,
//           debugShowCheckedModeBanner: false,
//           routerConfig: router,
//           //home: const TestPage(),
//           //  ),
//         );
//       },
//     );

//     // return MaterialApp.router(
//     //   title: 'ShikiDev',
//     //   theme: ThemeData(
//     //     useMaterial3: true,
//     //     brightness: Brightness.dark,
//     //     colorSchemeSeed: Colors.green,
//     //   ),
//     //   darkTheme: ThemeData(
//     //     useMaterial3: true,
//     //     brightness: Brightness.dark,
//     //     colorSchemeSeed: Colors.green,
//     //   ),
//     //   debugShowCheckedModeBanner: false,
//     //   routerConfig: router,
//     // );
//   }
// }

// class AuthTest extends StatefulWidget {
//   const AuthTest({super.key});

//   @override
//   State<AuthTest> createState() => _AuthTestState();
// }

// class _AuthTestState extends State<AuthTest> {
//   String _status = '';
//   String _code = '';

//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     isLoading = false;
//   }

//   void auth() async {
//     isLoading = true;
//     const callbackUrlScheme = 'shikidev';
//     const url =
//         'https://shikimori.one/oauth/authorize?client_id=52dpZiZh1N7IrjN0bp76SJJXsB8R6vAmxeqrgY3szcs&redirect_uri=shikidev%3A%2F%2Foauth%2Fshikimori&response_type=code&scope=user_rates';

//     try {
//       final result = await FlutterWebAuth.authenticate(
//           url: url, callbackUrlScheme: callbackUrlScheme);

//       // Extract code from resulting url
//       final code = Uri.parse(result).queryParameters['code'];
//       _code = code ?? 'Extract code error';

//       setState(() {
//         _status = 'Got result: $result';
//       });
//     } on Exception catch (e) {
//       final expString = e.toString();
//       setState(() {
//         isLoading = false;
//         // if (expString.contains('CANCELED')) {
//         //   _showSnackbar('Пользователь отменил вход', 4);
//         //   _status = 'User canceled login';
//         // } else {
//         //   _showSnackbar('Unhandled exception', 4);
//         //   _status = 'Got error: $expString';
//         // }
//         //_status = 'Got error: $e';
//       });

//       if (expString.contains('CANCELED')) {
//         _showSnackbar('Пользователь отменил вход', 4);
//       } else {
//         _showSnackbar('Unhandled exception', 4);
//         _status = 'Got error: $expString';
//       }
//     }
//   }

//   void _showSnackbar(String msg, int dur) {
//     final snackBar = SnackBar(
//       content: Text(msg),
//       behavior: SnackBarBehavior.floating,
//       dismissDirection: DismissDirection.horizontal,
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 48),
//       //padding: const EdgeInsets.all(8),
//       duration: Duration(seconds: dur),
//       showCloseIcon: true,
//       //backgroundColor: Theme.of(context).colorScheme.onSurface,
//     );
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Scaffold(
//         body: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(30),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: const [
//                   CircularProgressIndicator(),
//                   SizedBox(
//                     height: 24,
//                   ),
//                   Text('Получение токена для входа'),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ShikiDev'),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(30),
//             child: Center(
//               child: SizedBox(
//                 width: 400,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       'Привет!',
//                       //textAlign: TextAlign.center,
//                       // style: TextStyle(
//                       //   fontSize: 32,
//                       //   color: Theme.of(context).colorScheme.primary,
//                       // ),
//                       style: Theme.of(context)
//                           .textTheme
//                           .headlineLarge
//                           ?.copyWith(
//                               color: Theme.of(context).colorScheme.primary),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Для использования приложения необходимо войти в аккаунт',
//                       //textAlign: TextAlign.center,
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                     const SizedBox(height: 48),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         auth();
//                       },
//                       icon: const Icon(
//                         Icons.login_outlined,
//                         //size: 32,
//                       ),
//                       label: const Text('Войти в аккаунт'),
//                     ),
//                     const SizedBox(height: 4),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         setState(() {
//                           isLoading = true;
//                         });
//                       },
//                       icon: const Icon(
//                         Icons.person_add_outlined,
//                         //size: 32,
//                       ),
//                       label: const Text('Создать новый'),
//                     ),

//                     // const SizedBox(height: 4),
//                     // ElevatedButton(
//                     //   onPressed: () {},
//                     //   child: Stack(
//                     //     alignment: AlignmentDirectional.centerStart,
//                     //     children: const [
//                     //       Align(
//                     //         widthFactor: 1,
//                     //         alignment: Alignment.centerLeft,
//                     //         child: Icon(
//                     //           Icons.settings_outlined,
//                     //         ),
//                     //       ),
//                     //       Align(
//                     //         widthFactor: 3,
//                     //         alignment: Alignment.center,
//                     //         child: Text('Настройки'),
//                     //       ),
//                     //       //Text('Настройки'),
//                     //     ],
//                     //   ),
//                     // ),
//                     const SizedBox(height: 4),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         _showSnackbar('settings', 2);
//                       },
//                       icon: const Icon(
//                         Icons.settings_outlined,
//                         //size: 32,
//                       ),
//                       label: const Text('Настройки'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );

//     // return Scaffold(
//     //   // appBar: AppBar(
//     //   //   title: const Text('Web Auth example'),
//     //   // ),
//     //   body: Center(
//     //     child: Column(
//     //       mainAxisAlignment: MainAxisAlignment.center,
//     //       children: <Widget>[
//     //         Text('Status: $_status\n'),
//     //         Text('Code: $_code\n'),
//     //         const SizedBox(height: 80),
//     //         ElevatedButton(
//     //           child: const Text('Auth'),
//     //           onPressed: () {
//     //             auth();
//     //           },
//     //         ),
//     //       ],
//     //     ),
//     //   ),
//     // );
//   }
// }
