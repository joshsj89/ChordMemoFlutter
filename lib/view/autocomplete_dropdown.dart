import 'package:flutter/material.dart';

class AutocompleteDropdown extends StatefulWidget {
  final List<String> suggestions;
  final String hintText;
  final TextStyle hintStyle;
  final ValueChanged<String> onChanged;
  final TextStyle style;
  final BorderSide borderSide;
  final Color suggestionListBackgroundColor;
  final int maxVisibleSuggestions;

  const AutocompleteDropdown({
    super.key,
    required this.suggestions,
    required this.hintText,
    this.hintStyle = const TextStyle(color: Colors.grey),
    required this.onChanged,
    this.style = const TextStyle(),
    this.borderSide = const BorderSide(),
    this.suggestionListBackgroundColor = Colors.white,
    this.maxVisibleSuggestions = 4,
  });

  @override
  State<AutocompleteDropdown> createState() => _AutocompleteDropdownState();
}

class _AutocompleteDropdownState extends State<AutocompleteDropdown> {
  final TextEditingController _controller = TextEditingController(); // Controller for the text field
  final FocusNode _focusNode = FocusNode(); // for handling focus events
  List<String> _filteredSuggestions = []; // Suggestions that match the current input
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    final input = _controller.text.toLowerCase();

    setState((){
    _filteredSuggestions = widget.suggestions
      .where((suggestion) => suggestion.toLowerCase().contains(input))
      .toList();

      _showDropdown = input.isNotEmpty && _filteredSuggestions.isNotEmpty;
    });

    widget.onChanged(input);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _onTextChanged();
    } else {
      setState(() {
        _showDropdown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: widget.style,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: widget.hintStyle,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        _controller.clear();
                        _showDropdown = false;
                      });
                    },
                  ),

                IconButton(
                  icon: Icon(Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _showDropdown = !_showDropdown;
                    });
                  }
                )
              ]
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: widget.borderSide,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: widget.borderSide,
            ),
          ),
        ),

        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: widget.borderSide.color),
              borderRadius: BorderRadius.circular(4),
              color: widget.suggestionListBackgroundColor,
            ),
            constraints: BoxConstraints(
              maxHeight: (widget.maxVisibleSuggestions * 56.0).toDouble(), // 56.0 is the height of a ListTile
            ),
            child: ListView.builder(
              shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(), // Disable scrolling
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _filteredSuggestions[index], 
                    style: widget.style,
                  ),
                  onTap: () {
                    setState(() {
                      _controller.text = _filteredSuggestions[index];
                      _showDropdown = false;
                    });

                    widget.onChanged(_filteredSuggestions[index]);
                  }
                );
              }
            )
          )
      ],
    );
  }

  @override
  void dispose() { // Clean up the controller and focus node when the widget is disposed
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}