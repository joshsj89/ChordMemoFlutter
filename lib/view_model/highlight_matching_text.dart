import 'package:flutter/material.dart';

List<TextSpan> highlightMatchingText(String suggestion, String query, TextStyle style) {
  final List<TextSpan> spans = []; // List of spans to return
  final String lowerSuggestion = suggestion.toLowerCase();
  final String lowerQuery = query.toLowerCase();

  if (query.isEmpty) {
    return [TextSpan(text: suggestion, style: style)];
  }

  int start = 0;
  int indexOfMatch = lowerSuggestion.indexOf(lowerQuery, start);

  while (indexOfMatch != -1) {
    // Add non-matching text before the match
    if (indexOfMatch > start) {
      spans.add(TextSpan(
        text: suggestion.substring(start, indexOfMatch),
        style: style,
      ));
    }

    // Add the matching text with a bold style
    spans.add(TextSpan(
      text: suggestion.substring(indexOfMatch, indexOfMatch + query.length),
      style: style.copyWith(fontWeight: FontWeight.bold),
    ));

    // Update the start index and find the next match
    start = indexOfMatch + query.length;
    indexOfMatch = lowerSuggestion.indexOf(lowerQuery, start);
  }

  // Add the remaining non-matching text
  if (start < suggestion.length) {
    spans.add(TextSpan(
      text: suggestion.substring(start),
      style: style,
    ));
  }

  return spans;
}