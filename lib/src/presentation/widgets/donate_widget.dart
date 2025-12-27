import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/extensions/buildcontext.dart';
import '../../utils/app_utils.dart';

class DonateWidget extends StatelessWidget {
  const DonateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
                        'Поддержать разработку',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600,
                          color: context.colorScheme.onTertiaryContainer,
                        ),
                      ),
                      Text(
                        'Понравилось приложение?\nТы можешь сделать добровольное пожертвование, чем очень поможешь в разработке',
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
  }
}

class _DonateBottomSheet extends StatelessWidget {
  const _DonateBottomSheet();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Поддержать разработку',
              style: context.textTheme.headlineMedium,
            ),
          ),
          Card(
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                ),
                // ListTile(
                //   onTap: () => launchUrlString(
                //     'https://pay.cloudtips.ru/p/f63a121a',
                //     mode: LaunchMode.externalApplication,
                //   ),
                //   leading: const Icon(
                //     Icons.payment_rounded,
                //     size: 24,
                //   ),
                //   title: const Text('CloudTips'),
                // ),
                ListTile(
                  onTap: () => Clipboard.setData(
                    const ClipboardData(
                      text: 'UQBVpx70dPMLfITCwrSB_OdulvjkF5cAZGl63lg_0anH-iSa',
                    ),
                  ).then((_) => Navigator.of(context).pop()).then((_) =>
                      showSnackBar(
                          ctx: context,
                          msg: 'Адрес TON скопирован в буфер обмена',
                          dur: const Duration(seconds: 3))),
                  leading: const Icon(
                    Icons.diamond_rounded,
                    size: 24,
                  ),
                  title: const Text('Toncoin (TON)'),
                ),
                ListTile(
                  onTap: () => Clipboard.setData(
                    const ClipboardData(
                      text: 'TAGb4sjk4YE6MgPLxFiNuEUwJyD1nyoEgr',
                    ),
                  ).then((_) => Navigator.of(context).pop()).then((_) =>
                      showSnackBar(
                          ctx: context,
                          msg: 'Адрес USDT TRC20 скопирован в буфер обмена',
                          dur: const Duration(seconds: 3))),
                  leading: SvgPicture.asset(
                    'assets/svg/usdt.svg',
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: const Text('USDT TRC20'),
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
                ),
              ],
            ),
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
