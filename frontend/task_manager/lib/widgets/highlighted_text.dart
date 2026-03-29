import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle? style;
  final TextStyle? highlightStyle;

  const HighlightedText({
    Key? key,
    required this.text,
    required this.highlight,
    this.style,
    this.highlightStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) {
      return Text(text, style: style);
    }

    final String lowerText = text.toLowerCase();
    final String lowerHighlight = highlight.toLowerCase();
    final List<TextSpan> spans = [];
    
    int start = 0;
    int indexOfHighlight;
    
    while ((indexOfHighlight = lowerText.indexOf(lowerHighlight, start)) != -1) {
      if (indexOfHighlight > start) {
        spans.add(TextSpan(
          text: text.substring(start, indexOfHighlight),
          style: style,
        ));
      }
      
      spans.add(TextSpan(
        text: text.substring(indexOfHighlight, indexOfHighlight + highlight.length),
        style: highlightStyle ?? TextStyle(
          backgroundColor: Colors.yellow.shade200,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ));
      
      start = indexOfHighlight + highlight.length;
    }
    
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
