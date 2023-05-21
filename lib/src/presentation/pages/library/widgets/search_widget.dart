import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  final String text;
  final void Function(String)? onChanged;
  final String hintText;
  final TextEditingController controller;

  const SearchWidget({
    Key? key,
    required this.text,
    required this.onChanged,
    required this.hintText,
    required this.controller,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context) //onInverseSurface  primaryContainer
            .colorScheme
            .surfaceVariant,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          icon: const Icon(Icons.search_outlined),
          suffixIcon: widget.controller.text.isNotEmpty
              ? GestureDetector(
                  child: const Icon(Icons.close),
                  onTap: () {
                    widget.controller.clear();
                    widget.onChanged!('');
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                )
              : null,
          hintText: widget.hintText,
          border: InputBorder.none,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
