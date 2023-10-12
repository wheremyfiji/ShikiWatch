import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../utils/extensions/buildcontext.dart';

class DonateWidget extends StatelessWidget {
  const DonateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      //clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        // border: Border.all(
        //   color: context.colorScheme.surfaceVariant,
        // ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.tertiaryContainer,
            context.colorScheme.secondaryContainer,
            //context.colorScheme.primaryContainer,
          ],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
      ),
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
        color: Colors.transparent,
        child: InkWell(
          //onTap: () => _DonateBottomSheet.show(context),
          onTap: () => launchUrlString(
            'https://new.donatepay.ru/@1156478',
            mode: LaunchMode.externalApplication,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.currency_yen_rounded, //currency_yen_rounded
                      size: 32.0,
                      color: context.colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(
                      width: 6.0,
                    ),
                    Flexible(
                      child: Text(
                        'Поддержать разработчика',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600,
                          color: context.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0, top: 6.0),
                  child: Text(
                    'Вы можете оформить добровольное пожертвование для дальнейшего развития приложения',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: context.colorScheme.onTertiaryContainer
                          .withOpacity(0.8),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 6.0),
                //   child: Text(
                //     'Мне будет очень приятно, а также я смогу купить очередную баночку енергетика...',
                //     style: TextStyle(
                //       fontSize: 12.0,
                //       color: context.colorScheme.onTertiaryContainer
                //           .withOpacity(0.6),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );

    // return Container(
    //   clipBehavior: Clip.hardEdge,
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
    //       ],
    //     ),
    //     borderRadius: const BorderRadius.all(Radius.circular(12)),
    //   ),
    //   child: Material(
    //     clipBehavior: Clip.hardEdge,
    //     borderRadius: const BorderRadius.all(Radius.circular(12)),
    //     color: Colors.transparent,
    //     child: InkWell(
    //       onTap: () {},
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    //         child: Row(
    //           //crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Icon(
    //               Icons.currency_yen_rounded, //currency_yen_rounded
    //               size: 32,
    //               color: context.colorScheme.onTertiaryContainer,
    //             ),
    //             const SizedBox(
    //               width: 6.0,
    //             ),
    //             Expanded(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     'Поддержать разработчика',
    //                     style: TextStyle(
    //                       fontSize: 22,
    //                       fontWeight: FontWeight.w500,
    //                       color: context.colorScheme.onTertiaryContainer,
    //                     ),
    //                   ),
    //                   const SizedBox(
    //                     height: 6.0,
    //                   ),
    //                   Text(
    //                     'Вы можете оформить добровольное пожертвование для дальнейшего развития приложения.',
    //                     style: TextStyle(
    //                       fontSize: 14,
    //                       color: context.colorScheme.onTertiaryContainer
    //                           .withOpacity(0.8),
    //                     ),
    //                   ),
    //                   const SizedBox(
    //                     height: 4.0,
    //                   ),
    //                   Text(
    //                     'Мне будет очень приятно, а также я смогу купить очередную баночку енергетика...',
    //                     style: TextStyle(
    //                       fontSize: 12,
    //                       color: context.colorScheme.onTertiaryContainer
    //                           .withOpacity(0.6),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class _DonateBottomSheet extends StatelessWidget {
  // ignore: unused_element
  const _DonateBottomSheet({super.key});

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
              style: context.textTheme.headlineSmall,
            ),
          ),
          ListTile(
            onTap: () => launchUrlString(
              'https://new.donatepay.ru/@1156478',
              mode: LaunchMode.externalApplication,
            ),
            leading: const Icon(Icons.attach_money_rounded),
            title: const Text('DonatePay'),
            subtitle: const Text('Множество способов оплаты'),
          ),
          ListTile(
            onTap: () => launchUrlString(
              'https://yoomoney.ru/to/410018275149576',
              mode: LaunchMode.externalApplication,
            ),
            leading: const Icon(Icons.account_balance_wallet_rounded),
            title: const Text('ЮMoney'),
            subtitle: const Text('С кошелька или карты любого банка России'),
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
