import 'package:flutter/material.dart';

class LibraryPageAppBar extends StatelessWidget {
  final bool innerBoxIsScrolled;

  const LibraryPageAppBar(
    this.innerBoxIsScrolled, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      forceElevated: innerBoxIsScrolled,
      pinned: true,
      floating: true,
      snap: false,
      title: const Text('Аниме'),
      // actions: [
      //   IconButton(
      //     onPressed: () async {
      //       // await extended_image.clearDiskCachedImages();
      //       // extended_image.clearMemoryImageCache();

      //       // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //       //   content: Text('Кеш очищен'),
      //       //   duration: Duration(seconds: 3),
      //       // ));
      //     },
      //     icon: const Icon(Icons.delete),
      //   ),
      // ],
      // titleTextStyle: Theme.of(context)
      //   .textTheme
      //   .headline6
      //   ?.copyWith(fontWeight: FontWeight.bold),
      //actions: [
      // controller.when(
      //   error: (error, stackTrace) {
      //     // return const Padding(
      //     //   padding: EdgeInsets.all(16.0),
      //     //   child: CircleAvatar(
      //     //     child: Icon(Icons.no_accounts),
      //     //   ),
      //     // );
      //     return const SizedBox.shrink();
      //     // return IconButton(
      //     //   onPressed: () => context.push('/my_animes/settings'),
      //     //   icon: const Icon(Icons.settings_outlined),
      //     // );
      //   },
      //   loading: () {
      //     return const Padding(
      //       padding: EdgeInsets.all(10.0),
      //       child: CircleAvatar(),
      //     );
      //   },
      //   data: (data) {
      //     // return CircleAvatar(
      //     //   child: CircularProgressIndicator(),
      //     // );
      //     return Padding(
      //       padding: const EdgeInsets.all(8.0), //10
      //       child: GestureDetector(
      //         onTap: () => context.push('/my_animes/settings'),
      //         child: CircleAvatar(
      //           // child: CircularProgressIndicator(
      //           //   strokeWidth: 3.0,
      //           // ),
      //           foregroundImage: CachedNetworkImageProvider(
      //             data,
      //           ),
      //         ),
      //       ),
      //     );
      //   },
      // ),
      //],
      bottom: TabBar(
        unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        isScrollable: true,
        // indicator: BoxDecoration(
        //     borderRadius: BorderRadius.circular(16), // Creates border
        //     color: Theme.of(context).colorScheme.onSecondary),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        //splashBorderRadius: BorderRadius.circular(16),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            return states.contains(MaterialState.focused)
                ? null
                : Colors.transparent;
          },
        ),
        tabs: const [
          Tab(
            //text: 'Избранное',
            text: 'История',
          ),
          Tab(
            text: 'Смотрю',
          ),
          Tab(
            text: 'В планах',
          ),
          Tab(
            text: 'Просмотрено',
          ),
          Tab(
            text: 'Пересматриваю',
          ),
          Tab(
            text: 'Отложено',
          ),
          Tab(
            text: 'Брошено',
          ),
        ],
      ),
    );
  }
}
