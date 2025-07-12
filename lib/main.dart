import 'dart:async';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/nav_bar.dart';
import 'package:light_novel_reader_client/components/navigation.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/auth/login.dart';
import 'package:light_novel_reader_client/pages/auth/register.dart';
import 'package:light_novel_reader_client/pages/favourites_view.dart';
import 'package:light_novel_reader_client/pages/history.dart';
import 'package:light_novel_reader_client/pages/search/search.dart';
import 'package:light_novel_reader_client/pages/settings/settings.dart';
import 'package:light_novel_reader_client/pages/sources.dart';
import 'package:light_novel_reader_client/pages/updates.dart';

Future<void> main() async {
  try {
    FlutterError.onError = (FlutterErrorDetails details) {
      logger.error('Flutter Error: ${details.exceptionAsString()}');
      FlutterError.dumpErrorToConsole(details); // Optionally log the error to the console
    };
    runZoned(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        await serverController.loadServerUrl();
        await authController.loadAuth();
        await uiController.loadUISettings();

        runApp(const MyApp());
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          logger.log(line);
          parent.print(zone, line);
        },
        errorCallback: (self, parent, zone, error, stackTrace) {
          logger.error(error.toString());
          parent.errorCallback(zone, error, stackTrace);
          return null;
        },
      ),
    );
  } catch (e, st) {
    print('Error in main(): $e\n$st');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (authController.auth.isAuthenticated) {
      // If the user is authenticated, fetch the sources and history
      uiController.getCategories();
      apiController.fetchSources();
      historyController.getHistory();
      favouritesController.getFavourites();
      updatesController.getUpdates();
    }
    return Obx(
      () => MaterialApp(
        title: 'Light Novel Reader',
        theme: FlexThemeData.light(
          // scheme: scheme,
          colorScheme: const ColorScheme.light(
              primary: Color(0xFF375778),
              secondary: Color.fromARGB(255, 139, 139, 139),
              tertiary: Color.fromARGB(230, 204, 204, 202),
              surface: Color(0xFFEEEEEE),
              onSurfaceVariant: Color(0xFF4F4F4F)),
          appBarElevation: 0,
          appBarBackground: Color(0xFFEEEEEE),
        ),
        darkTheme: FlexThemeData.dark(
          // scheme: ,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFC90F4D),
            secondary: Color(0xFFEBD4CB),
            tertiary: Color.fromARGB(255, 46, 46, 46),
            surface: Color(0xFF1E1E1E),
            onSurfaceVariant: Color(0xFFA8A8A8),
          ),
          appBarElevation: 0,
          appBarBackground: Color(0xFF1E1E1E),
        ),
        themeMode: themeMode.value,
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    if (authController.auth.isAuthenticated) {
      // If the user is authenticated, fetch the sources and history
      serverController.connectWebSocket(context: context);
    }

    return Obx(() {
      if (!serverController.serverResponse.success && !authController.auth.isAuthenticated) {
        return Scaffold(
          body: SettingsPage(),
        );
      }

      if (serverController.serverResponse.success && !authController.auth.isAuthenticated) {
        return Scaffold(
          body: MainNavigationBar(navItems: [
            NavBarItem(
              label: 'Login',
              icon: Icons.login,
              child: const LoginPage(),
              onTap: () {
                authController.clearFields();
                uiController.setPage(0);
              },
            ),
            if (serverController.canRegister)
              NavBarItem(
                label: 'Register',
                icon: Icons.app_registration,
                child: const RegisterPage(),
                onTap: () {
                  authController.clearFields();
                  uiController.setPage(1);
                },
              ),
            NavBarItem(
              label: 'Settings',
              icon: Icons.settings,
              child: SettingsPage(),
            ),
          ]),
        );
      }

      return Scaffold(
        body: MainNavigationBar(
          navItems: [
            NavBarItem(
              label: 'Favourites',
              icon: Icons.favorite,
              child: FavouritesView(),
            ),
            NavBarItem(
              label: 'Updates',
              icon: Icons.new_releases,
              child: UpdatesPage(),
            ),
            NavBarItem(
              label: 'History',
              icon: Icons.timer_outlined,
              child: History(),
            ),
            NavBarItem(
              label: 'Search',
              icon: Icons.search,
              child: (apiController.currentSource != "") ? SearchPage() : SourcesPage(),
            ),
            NavBarItem(
              label: 'Settings',
              icon: Icons.settings,
              child: SettingsPage(),
            ),
            NavBarItem(
              label: 'Logout',
              icon: Icons.logout,
              child: Container(),
              showInMobile: false,
              onTap: () async {
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
            ),
          ],
        ),
      );
    });
  }
}
