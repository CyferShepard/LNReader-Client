import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:light_novel_reader_client/classes/api.dart';
import 'package:light_novel_reader_client/components/text_field_editor.dart';
import 'package:light_novel_reader_client/controller/api_controller.dart';
import 'package:light_novel_reader_client/controller/auth_controller.dart';
import 'package:light_novel_reader_client/controller/favourites_controller.dart';
import 'package:light_novel_reader_client/controller/history_controller.dart';
import 'package:light_novel_reader_client/controller/server_controller.dart';
import 'package:light_novel_reader_client/controller/ui_controller.dart';

final ioc = GetIt.instance;
ServerController get serverController => Get.put(ServerController());

ApiClient client = ApiClient(baseUrl: serverController.serverUrl);

ApiController get apiController => Get.put(ApiController());

HistoryController get historyController => Get.put(HistoryController());
FavouritesController get favouritesController => Get.put(FavouritesController());
AuthController get authController => Get.put(AuthController());

UIController get uiController => Get.put(UIController());
final GlobalKey<TextFieldEditorState> serverUrlFieldKey = GlobalKey<TextFieldEditorState>();
final themeMode = ThemeMode.system.obs;
