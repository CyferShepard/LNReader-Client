import 'package:flutter/material.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

final List<Widget> platform_notification = [webNotification(), nativePlatformNotification()];

Positioned webNotification() {
  return Positioned.fill(
    child: Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'A new version is available!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please reload the page to update and clear cached files.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // For web: reload and clear cache
                    html.window.location.reload();
                    // For mobile: you might want to use a different method
                    // Navigator.of(context).pop(); // Close the dialog if needed
                  },
                  child: const Text('Reload Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Positioned nativePlatformNotification() {
  return Positioned.fill(
    child: Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'A new version is available!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please install the latest version.',
                  textAlign: TextAlign.center,
                ),
                if (latestVersionUrl != null) const SizedBox(height: 24),
                if (latestVersionUrl != null)
                  ElevatedButton(
                    onPressed: () async {
                      final url = latestVersionUrl;
                      if (url != null) {
                        try {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        } catch (e) {
                          // Optionally show an error to the user
                          print('Could not launch $url: $e');
                        }
                      }
                    },
                    child: Text('Get Latest Version: ${latestVersionUrl!}'),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class UpdateNotification extends StatelessWidget {
  const UpdateNotification({super.key});

  @override
  Widget build(BuildContext context) {
    Widget notification = platform_notification[0];
    if (platformType != 'web') {
      notification = platform_notification[1];
    }
    return notification;
  }
}
