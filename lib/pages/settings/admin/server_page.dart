import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/text_field_editor.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';

class ServerPage extends StatelessWidget {
  const ServerPage({super.key, this.isDesktop = false});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // SizedBox(height: context.isTabletOrDesktop ? 50 : 20),
          Row(
            children: [
              Text("Server", style: Theme.of(context).textTheme.headlineLarge),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.primary,
            thickness: 2,
          ),
          SizedBox(height: context.isTabletOrDesktop ? 50 : 20),
          TextFieldEditor(
            key: serverUrlFieldKey,
            initialValue: serverController.serverUrl,
            hintText: 'Password',
            icon: Icons.web,
            onSubmitted: (value) => serverController.serverUrl = value,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter your server url';
              }
              const validUrlPattern = r'^(https?|http)://[^\s/$.?#].[^\s]*$';
              final urlRegex = RegExp(validUrlPattern);
              if (!urlRegex.hasMatch(value)) {
                return 'Please enter a valid URL';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          if (serverController.serverResponse.success)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                serverController.serverResponse.message,
                style: TextStyle(
                    color: serverController.serverResponse.success ? Colors.greenAccent : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          if (serverController.serverResponse.success) const SizedBox(height: 39),
          ElevatedButton(
            onPressed: authController.isLoading
                ? null
                : () {
                    bool validUrl = serverUrlFieldKey.currentState?.validate() ?? false;

                    if (validUrl) {
                      // authController.changePassword();
                      serverController.connect();
                    }
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50), // Full width button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: authController.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                : const Text('Update Url', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
          if (authController.auth.isAdmin && serverController.serverResponse.success) const SizedBox(height: 16),
          if (authController.auth.isAdmin && serverController.serverResponse.success)
            ElevatedButton(
              onPressed: () {
                apiController.updateSources();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Full width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.extension,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Update Plugins',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          if (authController.auth.isAdmin && serverController.serverResponse.success) const SizedBox(height: 16),
          if (authController.auth.isAdmin && serverController.serverResponse.success)
            ElevatedButton(
              onPressed: () {
                serverController.toggleRegistration();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Full width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    serverController.canRegister ? Icons.cancel : Icons.app_registration,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    serverController.canRegister ? 'Disable Registration' : 'Enable Registration',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
