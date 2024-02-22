import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/extensions/buildcontext.dart';

class DonateWidget extends StatelessWidget {
  const DonateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // border: Border.all(
        //   color: context.colorScheme.onSurfaceVariant,
        // ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.tertiaryContainer,
            context.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _DonateBottomSheet.show(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 10, top: 10),
                child: Icon(
                  Icons.currency_yen_rounded, //currency_yen_rounded
                  size: 32.0,
                  color: context.colorScheme.onTertiaryContainer,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Поддержать разработчика',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600,
                          color: context.colorScheme.onTertiaryContainer,
                        ),
                      ),
                      Text(
                        //'Вы можете оформить добровольное пожертвование для дальнейшего развития приложения',
                        'Понравилось приложение? Ты можешь сделать добровольное пожертвование, чем очень поможешь в разработке',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: context.colorScheme.onTertiaryContainer
                              .withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // return Container(
    //   //clipBehavior: Clip.hardEdge,
    //   decoration: BoxDecoration(
    //     // border: Border.all(
    //     //   color: context.colorScheme.surfaceVariant,
    //     // ),
    //     gradient: LinearGradient(
    //       begin: Alignment.topLeft,
    //       end: Alignment.bottomRight,
    //       colors: [
    //         context.colorScheme.tertiaryContainer,
    //         context.colorScheme.secondaryContainer,
    //         //context.colorScheme.primaryContainer,
    //       ],
    //     ),
    //     borderRadius: const BorderRadius.all(Radius.circular(24.0)),
    //   ),
    //   child: Material(
    //     clipBehavior: Clip.hardEdge,
    //     borderRadius: const BorderRadius.all(Radius.circular(24.0)),
    //     color: Colors.transparent,
    //     child: InkWell(
    //       //onTap: () => _DonateBottomSheet.show(context),
    //       onTap: () => launchUrlString(
    //         'https://new.donatepay.ru/@1156478',
    //         mode: LaunchMode.externalApplication,
    //       ),
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(
    //           vertical: 12.0,
    //           horizontal: 8.0,
    //         ),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Row(
    //               children: [
    //                 Icon(
    //                   Icons.currency_yen_rounded, //currency_yen_rounded
    //                   size: 32.0,
    //                   color: context.colorScheme.onTertiaryContainer,
    //                 ),
    //                 const SizedBox(
    //                   width: 6.0,
    //                 ),
    //                 Flexible(
    //                   child: Text(
    //                     'Поддержать разработчика',
    //                     style: TextStyle(
    //                       fontSize: 22.0,
    //                       fontWeight: FontWeight.w600,
    //                       color: context.colorScheme.onTertiaryContainer,
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             Padding(
    //               padding: const EdgeInsets.only(left: 6.0, top: 6.0),
    //               child: Text(
    //                 //'Вы можете оформить добровольное пожертвование для дальнейшего развития приложения',
    //                 'Понравилось приложение? Ты можешь сделать добровольное пожертвование для дальнейшего развития ',
    //                 style: TextStyle(
    //                   fontSize: 14.0,
    //                   color: context.colorScheme.onTertiaryContainer
    //                       .withOpacity(0.8),
    //                 ),
    //               ),
    //             ),
    //             // Padding(
    //             //   padding: const EdgeInsets.only(left: 6.0),
    //             //   child: Text(
    //             //     'Мне будет очень приятно, а также я смогу купить очередную баночку енергетика...',
    //             //     style: TextStyle(
    //             //       fontSize: 12.0,
    //             //       color: context.colorScheme.onTertiaryContainer
    //             //           .withOpacity(0.6),
    //             //     ),
    //             //   ),
    //             // ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class _DonateBottomSheet extends StatelessWidget {
  const _DonateBottomSheet();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Поддержать разработчика',
              style: context.textTheme.headlineMedium,
            ),
          ),
          ListTile(
            onTap: () => launchUrlString(
              'https://boosty.to/wheremyfiji/donate',
              mode: LaunchMode.externalApplication,
            ),
            leading: SvgPicture.asset(
              'assets/svg/boosty.svg',
              height: 24,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            title: const Text('Boosty'),
            subtitle: const Text('Открыть в браузере'),
          ),
          ListTile(
            onTap: () => Clipboard.setData(
              const ClipboardData(
                text: 'UQBd8aIQ0TF0Oz_pXhX_yJPmh6GzzTj0hiwLk3OZbh0ZeBj7',
              ),
            ),
            leading: const Icon(
              Icons.diamond_rounded,
              //color: context.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            title: const Text('Toncoin (TON)'),
            subtitle: const Text('Скопировать адрес'),
          ),
          ListTile(
            onTap: () => Clipboard.setData(
              const ClipboardData(
                text: 'TRetqKdTt9CkkxXRPjtVT9mjFYpYUxnquE',
              ),
            ),
            leading: SvgPicture.asset(
              'assets/svg/usdt.svg',
              height: 24,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            title: const Text('USDT TRC20'),
            subtitle: const Text('Скопировать адрес'),
          ),
          ListTile(
            onTap: () => launchUrlString(
              'https://t.me/wheremyfiji',
              mode: LaunchMode.externalApplication,
            ),
            leading: const Icon(
              FontAwesomeIcons.telegram,
              size: 24,
            ),
            title: const Text('Telegram'),
            subtitle: const Text('Обсудить лично'),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      useRootNavigator: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
      ),
      builder: (_) => const SafeArea(child: _DonateBottomSheet()),
    );
  }
}
