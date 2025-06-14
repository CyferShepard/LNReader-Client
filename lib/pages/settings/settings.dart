import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/settings/account_page.dart';
import 'package:light_novel_reader_client/pages/settings/admin/server_page.dart';
import 'package:light_novel_reader_client/pages/settings/theme_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Obx(() {
        bool loggedIn = serverController.serverResponse.success && authController.auth.isAuthenticated;
        double width = context.width - (loggedIn ? 200 : 0);
        List<Widget> items = [
          if (loggedIn)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.isTabletOrDesktop ? math.max(width / 3, 300) : double.infinity,
                minWidth: context.isTabletOrDesktop ? 300 : 0,
              ),
              child: AccountPage(),
            ),
          SizedBox(
            width: context.isTabletOrDesktop ? 20 : 0,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: context.isTabletOrDesktop ? math.max(width / (loggedIn ? 3 : 2), 300) : double.infinity,
                minWidth: context.isTabletOrDesktop ? 300 : 0),
            child: ServerPage(),
          ),
          SizedBox(
            width: context.isTabletOrDesktop ? 20 : 0,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: context.isTabletOrDesktop ? math.max(width / (loggedIn ? 3 : 2), 300) : double.infinity,
                minWidth: context.isTabletOrDesktop ? 300 : 0),
            child: ThemePage(),
          )
        ];
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: context.isTabletOrDesktop
                ? Wrap(
                    children: items,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items,
                  ),
          ),
        );
      }),
    );
  }
}
