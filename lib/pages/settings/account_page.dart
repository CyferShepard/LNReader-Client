import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/text_field_editor.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<TextFieldEditorState> usernameFieldKey = GlobalKey<TextFieldEditorState>();
    final GlobalKey<TextFieldEditorState> passwordFieldKey = GlobalKey<TextFieldEditorState>();
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Account", style: Theme.of(context).textTheme.headlineLarge),
              ],
            ),
            Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 2,
            ),
            SizedBox(height: context.isTabletOrDesktop ? 50 : 20),
            TextFieldEditor(
              key: usernameFieldKey,
              initialValue: authController.auth.username,
              // label: "Username",
              hintText: "Username",
              icon: Icons.person,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFieldEditor(
              key: passwordFieldKey,
              initialValue: authController.secondaryPassword,
              hintText: 'Password',
              icon: Icons.lock,
              obscureText: true,
              onSubmitted: (value) => authController.secondaryPassword = value,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value == authController.auth.password) {
                  return 'New password cannot be the same as the old one';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            if (authController.auth.errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  authController.auth.errorMessage,
                  style: TextStyle(
                      color: authController.auth.isAuthenticated ? Colors.greenAccent : Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            if (!authController.auth.errorMessage.isNotEmpty) const SizedBox(height: 39),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: authController.isLoading
                  ? null
                  : () {
                      bool validUsername = usernameFieldKey.currentState?.validate() ?? false;
                      bool validPassword = passwordFieldKey.currentState?.validate() ?? false;
                      if (validUsername && validPassword) {
                        authController.auth = authController.auth.copyWith(
                          password: authController.secondaryPassword,
                        );
                        authController.changePassword();
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
                  : const Text('Update Password', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      );
    });
  }
}
