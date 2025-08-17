import 'package:flutter/material.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/settings/admin/server_page.dart';

class ServerErrorView extends StatelessWidget {
  const ServerErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Server Error',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your server connection or try again later.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await serverController.loadServerUrl();
              await authController.loadAuth();
              await uiController.loadUISettings();
            },
            child: const Text('Retry'),
          ),
          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Material(
                      child: Scaffold(
                          appBar: AppBar(
                            title: const Text('Server Settings'),
                            scrolledUnderElevation: 0,
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          body: Padding(padding: EdgeInsetsGeometry.directional(top: kToolbarHeight), child: ServerPage()))),
                ),
              );
            },
            child: const Text('Change Server Settings'),
          ),
        ],
      ),
    );
  }
}
