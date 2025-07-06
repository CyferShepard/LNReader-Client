import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/settings/account_page.dart';
import 'package:light_novel_reader_client/pages/settings/admin/server_page.dart';
import 'package:light_novel_reader_client/pages/settings/admin/user_management.dart';
import 'package:light_novel_reader_client/pages/settings/categories_page.dart';
import 'package:light_novel_reader_client/pages/settings/theme_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: const Text('Settings'),
          leading: uiController.settingsPage != 'main'
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    uiController.settingsPage = 'main';
                  },
                )
              : null,
        ),
        body: Obx(() {
          bool loggedIn = serverController.serverResponse.success && authController.auth.isAuthenticated;

          List<Widget> items = [
            if (loggedIn)
              ListTile(
                title: const Text('Account'),
                leading: const Icon(Icons.account_circle),
                onTap: () {
                  uiController.settingsPage = 'account';
                },
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            if (loggedIn)
              ListTile(
                title: const Text('Categories'),
                leading: const Icon(Icons.list),
                onTap: () {
                  uiController.settingsPage = 'categories';
                },
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            if (authController.auth.isAuthenticated && authController.auth.isAdmin)
              ListTile(
                title: const Text('Users'),
                leading: const Icon(Icons.supervised_user_circle),
                onTap: () {
                  uiController.settingsPage = 'users';
                },
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ListTile(
              title: const Text('Server Settings'),
              leading: const Icon(Icons.settings),
              onTap: () {
                uiController.settingsPage = 'server';
              },
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ListTile(
              title: const Text('Theme'),
              leading: const Icon(Icons.palette),
              onTap: () {
                uiController.settingsPage = 'theme';
              },
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            if (authController.auth.isAuthenticated && context.isMobile)
              ListTile(
                title: const Text('Logout'),
                leading: const Icon(Icons.logout),
                onTap: authController.isLoading
                    ? null
                    : () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Logout'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        if (shouldLogout == true) {
                          authController.logout();
                        }
                      },
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ];

          if (uiController.settingsPage == 'account') {
            return AccountPage();
          }

          if (uiController.settingsPage == 'categories') {
            return CategoriesPage();
          }

          if (uiController.settingsPage == 'server') {
            return ServerPage();
          }
          if (uiController.settingsPage == 'theme') {
            return ThemePage();
          }
          if (uiController.settingsPage == 'users') {
            return UserManagementPage();
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return items[index];
              },
            ),
          );
        }),
      ),
    );
  }
}
