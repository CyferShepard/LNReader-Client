import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  void initState() {
    super.initState();
    userController.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        onRefresh: () async {
          await userController.getUsers();
        },
        child: userController.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: userController.users.length,
                itemBuilder: (context, index) {
                  final user = userController.users[index];
                  return ListTile(
                    title: Text(user.username),
                    subtitle: Text('Username: ${user.username}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.password),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Change Password'),
                              content: TextField(
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'New Password',
                                ),
                                onSubmitted: (newPassword) {
                                  userController.resetUserPassword(user.username, newPassword);
                                  Navigator.of(context).pop();
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
