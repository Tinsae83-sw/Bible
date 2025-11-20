import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../widgets/settings_text.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _availableFonts = [
    'NotoSansEthiopic',
    'Roboto',
    'AbyssinicaSIL'
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final bool isDarkMode = settings.darkMode;
    final Color primaryColor =
        isDarkMode ? Colors.blue[200]! : const Color.fromARGB(255, 25, 75, 200);
    final Color backgroundColor =
        isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color appBarColor = isDarkMode
        ? Colors.grey[800]!
        : const Color.fromARGB(255, 65, 105, 225);
    final Color cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: SettingsText(
          'Setting',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
      ),
      body: Container(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Dark Mode Setting
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingsText(
                        'dark mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: SettingsText('dark mode'),
                        value: settings.darkMode,
                        activeColor: primaryColor,
                        onChanged: (bool value) {
                          settings.updateDarkMode(value);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Brightness Setting
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingsText(
                        'Brightness: ${(settings.brightness * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: settings.brightness,
                        min: 0.2,
                        max: 1.0,
                        divisions: 10,
                        activeColor: primaryColor,
                        inactiveColor: primaryColor.withOpacity(0.3),
                        label:
                            '${(settings.brightness * 100).toStringAsFixed(0)}%',
                        onChanged: (double value) {
                          settings.updateBrightness(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Font Family Setting
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingsText(
                        'የፊደል አይነት',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: isDarkMode ? Colors.grey[700] : Colors.white,
                        ),
                        child: DropdownButton<String>(
                          value: settings.fontFamily,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor:
                              isDarkMode ? Colors.grey[800] : Colors.white,
                          icon:
                              Icon(Icons.arrow_drop_down, color: primaryColor),
                          items: _availableFonts.map((String font) {
                            return DropdownMenuItem<String>(
                              value: font,
                              child: SettingsText(
                                font == 'NotoSansEthiopic'
                                    ? 'ኖቶ ሳንስ ኢትዮፒክ'
                                    : font == 'AbyssinicaSIL'
                                        ? 'አቢሲኒካ ኤስአይኤስ'
                                        : font,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              settings.updateFontFamily(newValue);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Font Size Setting
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingsText(
                        'የፊደል መጠን: ${settings.fontSize.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: settings.fontSize,
                        min: 8.0,
                        max: 32.0,
                        divisions: 24,
                        activeColor: primaryColor,
                        inactiveColor: primaryColor.withOpacity(0.3),
                        label: settings.fontSize.toStringAsFixed(1),
                        onChanged: (double value) {
                          settings.updateFontSize(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Preview Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingsText(
                        'እይታ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: isDarkMode ? Colors.grey[700] : Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const SizedBox(height: 16),
                            SettingsText(
                              'ዮሐንስ ፫:፲፮',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SettingsText(
                              'እግዚአብሔር ለዓለም ፍቅር አደረገላትና እንደሆነም አንድያ ልጁን ለሚያምን ሁሉ ላለመጥፋት ግን የዘላለም ሕይወት እንዲኖረው ሰጠ።',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
