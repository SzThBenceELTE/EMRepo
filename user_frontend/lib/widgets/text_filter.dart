import 'package:flutter/material.dart';

class TextFilter extends StatefulWidget {
  final void Function(String) onTextChanged;
  final String hintText;
  final IconData prefixIcon;

  const TextFilter({
    super.key,
    required this.onTextChanged,
    this.hintText = 'Filter by name',
    this.prefixIcon = Icons.search,
  });

  @override
  _TextFilterState createState() => _TextFilterState();
}

class _TextFilterState extends State<TextFilter> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      widget.onTextChanged(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(widget.prefixIcon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
