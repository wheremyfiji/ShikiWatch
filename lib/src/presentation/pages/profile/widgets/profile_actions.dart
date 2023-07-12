import 'package:flutter/material.dart';
import 'package:shikidev/src/presentation/pages/profile/user_history_page.dart';

class ProfileActions extends StatelessWidget {
  final String userId;
  const ProfileActions(this.userId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Expanded(
              child: TextButton(
                onPressed: null,
                child: Column(
                  children: [
                    Icon(Icons.groups),
                    SizedBox(
                      height: 4,
                    ),
                    Text('Клубы', overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: TextButton(
                onPressed: null,
                child: Column(
                  children: [
                    Icon(Icons.favorite),
                    SizedBox(
                      height: 4,
                    ),
                    Text('Избранное', overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          UserHistoryPage(userId),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: const Column(
                  children: [
                    Icon(Icons.history_rounded),
                    SizedBox(
                      height: 4,
                    ),
                    Text('История', overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
