import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class SettingsText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const SettingsText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);

    final baseStyle = TextStyle(
      fontFamily: settings.fontFamily,
      fontSize: settings.fontSize,
      color: settings.darkMode ? Colors.white : Colors.black,
    );

    return Text(
      text,
      style: baseStyle.merge(style),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
