import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/nav_bar.dart';
import 'package:light_novel_reader_client/controller/favourites_controller.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/categories.dart';
import 'package:light_novel_reader_client/utils/env_loader.dart'
    if (dart.library.js_interop) 'package:light_novel_reader_client/utils/env_loader_web.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UIController extends GetxController {
  final navController = SideNavBarController();
  final RxSet<int> selectedChapters = <int>{}.obs;
  final _multiSelectMode = false.obs;
  bool get multiSelectMode => _multiSelectMode.value;

  final _categories = <Categories>[].obs;
  List<Categories> get categories => _categories.toList();
  set categories(List<Categories> value) {
    _categories.value = value;
  }

  final _isCategoriesLoading = false.obs;
  bool get isCategoriesLoading => _isCategoriesLoading.value;
  set isCategoriesLoading(bool value) {
    _isCategoriesLoading.value = value;
  }

  final _settingsPage = 'main'.obs;
  String get settingsPage => _settingsPage.value;
  set settingsPage(String value) {
    _settingsPage.value = value;
  }

  final _searchPage = 'sources'.obs;
  String get searchPage => _searchPage.value;
  set searchPage(String value) {
    _searchPage.value = value;
  }

  final _isSubSearch = false.obs;
  bool get isSubSearch => _isSubSearch.value;
  set isSubSearch(bool value) {
    _isSubSearch.value = value;
  }

  final _fontSize = 18.0.obs;
  double get fontSize => _fontSize.value;
  set fontSize(double value) {
    if (value < 10 || value > 30) {
      throw Exception('Font size must be between 10 and 30');
    }
    _fontSize.value = value;
    saveUISettings();
  }

  final _fontColor = 0.obs;
  int get fontColor => _fontColor.value;
  set fontColor(int value) {
    _fontColor.value = value;
    saveUISettings();
  }

  final _lineHeight = 1.5.obs;
  double get lineHeight => _lineHeight.value;
  set lineHeight(double value) {
    if (value < 1.0 || value > 3.0) {
      throw Exception('Line height must be between 1.0 and 3.0');
    }
    _lineHeight.value = value;
    saveUISettings();
  }

  final _hasUpdates = false.obs;
  bool get hasUpdates => _hasUpdates.value;
  set hasUpdates(bool value) {
    _hasUpdates.value = value;
  }

  final _initialDataLoaded = false.obs;
  bool get initialDataLoaded => _initialDataLoaded.value;
  void markInitialDataLoaded() => _initialDataLoaded.value = true;
  void resetInitialDataLoaded() => _initialDataLoaded.value = false;

  final _allowChangeServerOnError = true.obs;
  bool get allowChangeServerOnError => _allowChangeServerOnError.value;
  set allowChangeServerOnError(bool value) {
    _allowChangeServerOnError.value = value;
  }

  void setPage(int index) {
    if (index < 0 || index >= navController.itemsCount) {
      throw Exception('Index out of bounds');
    }
    navController.select(index);
  }

  Future<void> saveUISettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'uiSettings',
        jsonEncode({
          'fontSize': fontSize,
          'lineHeight': lineHeight,
          'fontColor': fontColor,
          'darkMode': themeMode.value == ThemeMode.dark,
          'favouritesSortOrder': favouritesController.sortOrder.index,
          'favouritesSortAsc': favouritesController.sortAsc,
          'chapterSortOrder': apiController.sortAsc,
        }));
  }

  toggleDarkMode() {
    if (themeMode.value == ThemeMode.dark) {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.dark;
    }
    saveUISettings();
  }

  Future<void> getCategories() async {
    isCategoriesLoading = true;
    await client.getCategories().then((value) {
      _categories.value = value;
    }).catchError((error) {
      print('Error fetching categories: $error');
    });
    isCategoriesLoading = false;
  }

  Future<void> addCategory(String name) async {
    isCategoriesLoading = true;
    await client.addCategory(name).then((value) {
      if (value == true) {
        getCategories(); // Refresh categories after adding
      }
    }).catchError((error) {
      print('Error adding category: $error');
    });
    isCategoriesLoading = false;
  }

  Future<void> deleteCategory(String name) async {
    isCategoriesLoading = true;
    await client.deleteCategory(name).then((value) async {
      if (value == true) {
        await getCategories(); // Refresh categories after deletion
        await favouritesController.getFavourites(); // Refresh favourites after deletion
      }
    }).catchError((error) {
      print('Error deleting category: $error');
    });
    isCategoriesLoading = false;
  }

  Future<void> loadUISettings() async {
    final prefs = await SharedPreferences.getInstance();

    final settings = prefs.getString('uiSettings');
    if (settings != null) {
      final data = jsonDecode(settings);
      fontSize = data['fontSize']?.toDouble() ?? 18.0;
      lineHeight = data['lineHeight']?.toDouble() ?? 1.5;
      fontColor = data['fontColor'] ?? 0; // Default to 0 if not set
      if (data['darkMode'] != null) {
        themeMode.value = data['darkMode'] ? ThemeMode.dark : ThemeMode.light;
      } else {
        themeMode.value = ThemeMode.dark; // Default to system theme
      }
      favouritesController.sortOrder = SortBy.values[data['favouritesSortOrder'] ?? 0];
      favouritesController.sortAsc = data['favouritesSortAsc'] ?? true;
      apiController.sortAsc = data['chapterSortOrder'] ?? true;
    } else {
      // Set default values if no settings are found
      fontSize = 18.0;
      lineHeight = 1.5;
      fontColor = 0; // Default to 0 if not set
    }

    allowChangeServerOnError = allowChangeServerFromEnv();
  }

  void toggleChapterSelection(int index) {
    if (selectedChapters.contains(index)) {
      selectedChapters.remove(index);
    } else {
      selectedChapters.add(index);
    }
    _multiSelectMode.value = selectedChapters.isNotEmpty;
  }

  void clearChapterSelection() {
    selectedChapters.clear();
    _multiSelectMode.value = false;
  }

  void selectAllChapters(int totalChapters) {
    selectedChapters.addAll(List.generate(totalChapters, (i) => i + 1));
    _multiSelectMode.value = true;
  }
}
