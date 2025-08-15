import 'package:flutter/material.dart';
import 'package:light_novel_reader_client/globals.dart';

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
        ],
      ),
    );
  }
}
