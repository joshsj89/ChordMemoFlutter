import 'package:flutter/material.dart';

/// Shows the "Add Genre" dialog used by both the add- and edit-song screens.
///
/// [availableGenres] is the list of genres that can still be picked (built-in
/// genres plus previously-used ones, minus the genres already chosen for this
/// song). Typing filters that list; if the typed text doesn't match an existing
/// option a "Create" entry appears so the user can add a brand-new genre.
/// [onGenreSelected] receives either an existing option or the freshly typed
/// genre (already trimmed).
Future<void> showAddGenreDialog({
  required BuildContext context,
  required List<String> availableGenres,
  required Color backgroundColor,
  required Color textColor,
  required void Function(String genre) onGenreSelected,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return _AddGenreDialog(
        availableGenres: availableGenres,
        backgroundColor: backgroundColor,
        textColor: textColor,
        onGenreSelected: onGenreSelected,
      );
    },
  );
}

class _AddGenreDialog extends StatefulWidget {
  final List<String> availableGenres;
  final Color backgroundColor;
  final Color textColor;
  final void Function(String genre) onGenreSelected;

  const _AddGenreDialog({
    required this.availableGenres,
    required this.backgroundColor,
    required this.textColor,
    required this.onGenreSelected,
  });

  @override
  State<_AddGenreDialog> createState() => _AddGenreDialogState();
}

class _AddGenreDialogState extends State<_AddGenreDialog> {
  final TextEditingController _controller = TextEditingController();

  void _select(String genre) {
    widget.onGenreSelected(genre);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.textColor;

    final query = _controller.text.trim();
    final queryLower = query.toLowerCase();

    final filtered = widget.availableGenres
        .where((genre) => genre.toLowerCase().contains(queryLower))
        .toList();
    final hasExactMatch = widget.availableGenres
        .any((genre) => genre.toLowerCase() == queryLower);
    final showCreateOption = query.isNotEmpty && !hasExactMatch;

    return AlertDialog(
      title: Text(
        'Add Genre',
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: widget.backgroundColor,
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              style: TextStyle(color: textColor),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Search or create a genre',
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (showCreateOption) _select(query);
              },
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (showCreateOption)
                    ListTile(
                      leading: Icon(Icons.add, color: textColor),
                      title: Text(
                        'Create "$query"',
                        style: TextStyle(color: textColor),
                      ),
                      onTap: () => _select(query),
                    ),
                  ...filtered.map((genre) {
                    return ListTile(
                      title: Text(
                        genre,
                        style: TextStyle(color: textColor),
                      ),
                      onTap: () => _select(genre),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
