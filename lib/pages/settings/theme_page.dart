import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // SizedBox(height: context.isTabletOrDesktop ? 50 : 20),
          Row(
            children: [
              Text("Theme", style: Theme.of(context).textTheme.headlineLarge),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.primary,
            thickness: 2,
          ),
          SizedBox(height: context.isTabletOrDesktop ? 50 : 20),
          Row(
            children: [
              const Icon(Icons.brightness_6),
              const SizedBox(width: 8),
              const Text('Dark Mode'),
              const Spacer(),
              Obx(() => Switch(
                    value: themeMode.value == ThemeMode.dark,
                    onChanged: (val) {
                      uiController.toggleDarkMode();
                    },
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
