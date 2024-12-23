import 'package:flutter/material.dart';

import '../view_model/highlight_matching_text.dart';

class AutocompleteDropdown extends StatefulWidget {
  final List<String> dataset;
  final String hintText;
  final TextStyle hintStyle;
  final TextEditingController? controller;
  final bool shouldDisposeController;
  final ValueChanged<String> onChanged;
  final TextStyle style;
  final BorderSide borderSide;
  final Color suggestionListBackgroundColor;
  final int maxVisibleSuggestions;
  final bool caseSensitive;

  const AutocompleteDropdown({
    super.key,
    required this.dataset,
    required this.hintText,
    this.hintStyle = const TextStyle(color: Colors.grey),
    this.controller,
    this.shouldDisposeController = false,
    required this.onChanged,
    this.style = const TextStyle(),
    this.borderSide = const BorderSide(),
    this.suggestionListBackgroundColor = Colors.white,
    this.maxVisibleSuggestions = 4,
    this.caseSensitive = false,
  });

  @override
  State<AutocompleteDropdown> createState() => _AutocompleteDropdownState();
}

class _AutocompleteDropdownState extends State<AutocompleteDropdown> {
  final FocusNode _focusNode = FocusNode(); // for handling focus events
  final LayerLink _layerLink = LayerLink(); // for positioning the suggestion list
  OverlayEntry? _overlayEntry; // The overlay entry for the suggestion list

  List<String> _suggestionList = []; // Suggestions that match the current input
  bool _showDropdown = false;

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  // Initialize the filtered suggestions when the dataset changes
  @override
  void didUpdateWidget(covariant AutocompleteDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dataset != widget.dataset) { // If the dataset has changed
      _suggestionList = widget.dataset
        .where((suggestion) => suggestion.toLowerCase().contains(_controller.text.toLowerCase()))
        .toList();
    }
  }

  void _onTextChanged() {
    final input = _controller.text;
    final inputLower = input.toLowerCase();

    setState(() {
      if (!widget.caseSensitive) {
        _suggestionList = widget.dataset
          .where((suggestion) => suggestion.toLowerCase().contains(inputLower))
          .toList();
      } else {
        _suggestionList = widget.dataset
          .where((suggestion) => suggestion.contains(input))
          .toList();
      }

      _showDropdown = input.isNotEmpty && _suggestionList.isNotEmpty;
      _updateOverlay();
    });

    widget.onChanged(input);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _onTextChanged();
    } else {
      _hideOverlay();
    }
  }

  void _updateOverlay() {
    if (_showDropdown) {
      _overlayEntry?.remove();
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _hideOverlay();
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    setState(() {
      _showDropdown = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox; // Get the render box of the text field
    final Size size = renderBox.size; // Get the size of the text field
    final Offset offset = renderBox.localToGlobal(Offset.zero); // Get the global position of the text field

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx, // Set the left position to the x-coordinate of the text field
          top: offset.dy + size.height, // Set the top position to the y-coordinate of the text field + its height
          width: size.width, // Set the width to the width of the text field
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height),
            child: Material(
              elevation: 4,
              child: Container(
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
                  itemCount: _suggestionList.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: RichText(
                        text: TextSpan(
                          children: highlightMatchingText(_suggestionList[index], _controller.text, widget.style, widget.caseSensitive),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _controller.text = _suggestionList[index];
                          _hideOverlay();

                          widget.onChanged(_controller.text);
                        });

                        _focusNode.unfocus();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
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
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    _controller.clear();
                    _hideOverlay();
                  },
                ),
              AnimatedRotation(
                turns: _showDropdown ? 0.5 : 0, // 0.5*2*π = 1π = 180°
                duration: const Duration(milliseconds: 300),
                child: IconButton(
                  icon: const Icon(Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _showDropdown = !_showDropdown;
                    });

                    if (_showDropdown) {
                      _updateOverlay();
                    } else {
                      _hideOverlay();
                    }
                  },
                ),
              ),
            ],
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: widget.borderSide,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: widget.borderSide,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { // Clean up the controller and focus node when the widget is disposed
    if (widget.shouldDisposeController && widget.controller != null) {
      _controller.dispose();
    }


    _focusNode.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }
}