import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/text_field_editor.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<TextFieldEditorState> usernameFieldKey = GlobalKey<TextFieldEditorState>();
    final GlobalKey<TextFieldEditorState> passwordFieldKey = GlobalKey<TextFieldEditorState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Obx(() {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // Set your desired max width
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFieldEditor(
                    key: usernameFieldKey,
                    initialValue: authController.auth.username,
                    hintText: "Username",
                    icon: Icons.person,
                    onSubmitted: (value) => authController.auth = authController.auth.copyWith(username: value),
                    validator: (value) => value.isEmpty ? 'Please enter your username' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFieldEditor(
                    key: passwordFieldKey,
                    initialValue: authController.auth.password,
                    hintText: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                    onSubmitted: (value) => authController.auth = authController.auth.copyWith(password: value),
                    validator: (value) => value.isEmpty ? 'Please enter your password' : null,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: authController.isLoading
                            ? null
                            : () {
                                bool validUsername = usernameFieldKey.currentState?.validate() ?? false;
                                bool validPassword = passwordFieldKey.currentState?.validate() ?? false;
                                if (validUsername && validPassword) {
                                  authController.login();
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
                            : const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                      if (serverController.canRegister) SizedBox(height: context.isMobile ? 32 : 16),
                      if (serverController.canRegister)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don\'t have an account?'),
                            TextButton(
                              onPressed: () {
                                uiController.setPage(1);
                                authController.clearFields();
                              },
                              child: const Text('Register'),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      if (authController.auth.errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            authController.auth.errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (!authController.auth.errorMessage.isNotEmpty) const SizedBox(height: 39),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
