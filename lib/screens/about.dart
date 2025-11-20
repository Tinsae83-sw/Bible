import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const BibleApp());
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Holy Bible App',
      theme: ThemeData(
        primaryColor: const Color(0xFF0038B8), // Israel flag blue
        scaffoldBackgroundColor:
            const Color(0xFFF0F5FF), // Light blue background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0038B8),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const AboutScreen(),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Function to launch app store URL for rating
  Future<void> _rateApp() async {
    const appStoreUrl =
        'https://play.google.com/store/apps/details?id=com.future.bible_app_new';

    try {
      if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
        await launchUrl(Uri.parse(appStoreUrl));
      } else {
        throw 'Could not launch $appStoreUrl';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  // Function to share app
  Future<void> _shareApp() async {
    try {
      await Share.share(
        'Check out this amazing Holy Bible Application! '
        'Download it now: https://play.google.com/store/apps/details?id=com.future.bible_app_new',
        subject: 'Holy Bible Application',
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F5FF), // Very light blue
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon with subtle shadow
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0038B8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0038B8).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.book,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),
                // App Name
                const Text(
                  'Holy Bible Application',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0038B8),
                  ),
                ),
                const SizedBox(height: 30),
                // Version Information
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Version 1.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Developer Information Card
                _buildInfoCard(
                  icon: Icons.person,
                  title: 'Developer',
                  value: 'Tinsae',
                ),
                const SizedBox(height: 15),
                // Email Information Card
                _buildInfoCard(
                  icon: Icons.email,
                  title: 'Email',
                  value: 'tinsaesw23@gmail.com',
                ),
                const SizedBox(height: 40),
                // Rate Us Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _rateApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0038B8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 3,
                    ),
                    child: const Text(
                      'RATE US',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Share Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _shareApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0038B8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                            color: Color(0xFF0038B8), width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: const Text(
                      'SHARE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0038B8).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0038B8),
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0038B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
