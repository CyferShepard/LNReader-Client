import 'dart:async';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/nav_bar.dart';
import 'package:light_novel_reader_client/components/navigation.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/auth/login.dart';
import 'package:light_novel_reader_client/pages/auth/register.dart';
import 'package:light_novel_reader_client/pages/favourites_view.dart';
import 'package:light_novel_reader_client/pages/history.dart';
import 'package:light_novel_reader_client/pages/search/multiple_search_view.dart';
import 'package:light_novel_reader_client/pages/search/search.dart';
import 'package:light_novel_reader_client/pages/server_error.dart';
import 'package:light_novel_reader_client/pages/settings/settings.dart';
import 'package:light_novel_reader_client/pages/sources.dart';
import 'package:light_novel_reader_client/pages/updates.dart';
import 'package:universal_html/html.dart' as html;

updateChecker() {
  try {
    client.getVersion().then(
      (serverVersion) {
        if (serverVersion != null) {
          print('App version: $appVersion');
          print('latest version: $serverVersion');
          uiController.hasUpdates = compareVersions(appVersion, serverVersion) < 0;
          print('has updates: ${uiController.hasUpdates}');
        }
      },
    );
  } catch (e) {
    print('Error fetching server version: $e');
    uiController.hasUpdates = false; // Default to no updates if there's an error
  }
}

void startUpdateCheckerLoop() {
  // Run immediately once
  updateChecker();
  // Then run every 1 minute
  Timer.periodic(const Duration(minutes: 5), (timer) {
    updateChecker();
  });
}

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

        try {
          startUpdateCheckerLoop();
        } catch (e) {
          print('Error fetching app version: $e');
        }

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
    return Obx(() {
      if (authController.auth.isAuthenticated && !uiController.initialDataLoaded) {
        // If the user is authenticated, fetch the sources and history
        uiController.getCategories();
        apiController.fetchSources();
        historyController.getHistory();
        favouritesController.getFavourites();
        updatesController.getUpdates();
        uiController.markInitialDataLoaded();
      }
      return MaterialApp(
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
      );
    });
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
      // serverController.connectWebSocket(context: context);
    }

    return Obx(() {
      if (serverController.isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (!serverController.serverResponse.success && serverController.serverResponse.message.isNotEmpty) {
        return Scaffold(
          body: ServerErrorView(),
        );
      }

      if (!serverController.serverResponse.success && !authController.auth.isAuthenticated) {
        return Scaffold(
          body: SettingsPage(),
        );
      }

      if (uiController.hasUpdates && kIsWeb) {
        return Stack(
          children: [
            // Your normal navigation bar or home content
            Scaffold(
              body: MainNavigationBar(
                navItems: [
                  // ...your nav items...
                ],
              ),
            ),
            // Overlay for update notification
            Positioned.fill(
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
            ),
          ],
        );
      }

      if (serverController.serverResponse.success && !authController.auth.isAuthenticated) {
        return Stack(
          children: [
            Scaffold(
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
            ),
            if (uiController.hasUpdates && kIsWeb)
              Positioned.fill(
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
              ),
          ],
        );
      }

      return Stack(
        children: [
          Scaffold(
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
                  child: (uiController.searchPage == "globalSearch")
                      ? MultipleSearchView()
                      : ((uiController.searchPage == "search") ? SearchPage() : SourcesPage()),
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
                      uiController.resetInitialDataLoaded();
                      authController.logout();
                    }
                  },
                ),
              ],
              bottomNavItems: [
                NavBarItem(
                  label: themeMode.value == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
                  icon: themeMode.value == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                  child: Container(),
                  onTap: () {
                    uiController.toggleDarkMode();
                  },
                ),
              ],
            ),
          ),
          if (uiController.hasUpdates && kIsWeb)
            Positioned.fill(
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
            ),
        ],
      );
    });
  }
}
