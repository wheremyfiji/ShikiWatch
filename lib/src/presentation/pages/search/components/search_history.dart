import 'package:flutter/material.dart';

class AnimeSearchHistory extends StatelessWidget {
  final List<String> history;
  final Function(String) search;
  final VoidCallback clear;

  const AnimeSearchHistory(
      {super.key,
      required this.history,
      required this.search,
      required this.clear});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Divider(
            height: 1,
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                child: Text(
                  'История поиска',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 14,
                      ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: history.isEmpty ? null : () => clear(),
                child: const Text('Очистить'),
              ),
            ],
          ),
        ),
        if (history.isNotEmpty)
          SliverList.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final e = history[index];
              return ListTile(
                onTap: () => search(e),
                leading: const Icon(Icons.history),
                title: Text(
                  e,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
      ],
    );
  }
}
