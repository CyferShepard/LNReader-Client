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
  WidgetsFlutterBinding.ensureInitialized();
  await serverController.loadServerUrl();
  await authController.loadAuth();
  await uiController.loadUISettings();
  // ioc.registerSingleton<LayoutService>(LayoutService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (authController.auth.isAuthenticated) {
      // If the user is authenticated, fetch the sources and history
      apiController.fetchSources();
      historyController.getHistory();
      favouritesController.getFavourites();
      updatesController.getUpdates();
    }

    return Obx(
      () => MaterialApp(
        title: 'Light Novel Reader',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 82, 122, 255)).copyWith(
            secondary: const Color.fromARGB(255, 53, 51, 51),
            onSecondary: Colors.white,
            surface: Color.fromARGB(255, 195, 198, 202),
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color.fromARGB(255, 201, 15, 77),
            secondary: Color(0xFF1E1E1E),
            tertiary: Color.fromARGB(255, 53, 52, 51),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
          ),
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
