import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/text_field_editor.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  // Observables
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  final _auth = Rx<Auth>(Auth(username: '', password: ''));
  Auth get auth => _auth.value;
  set auth(Auth value) => _auth.value = value;

  final _secondaryPassword = ''.obs;
  String get secondaryPassword => _secondaryPassword.value;
  set secondaryPassword(String value) => _secondaryPassword.value = value;

  // Methods

  Future<void> saveAuth() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('auth', jsonEncode(auth.toJson()));
  }

  Future<void> loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final authString = prefs.getString('auth');
    if (authString != null) {
      // You may want to use jsonDecode here for a real JSON string
      final Map<String, dynamic> json = Map<String, dynamic>.from(
        jsonDecode(authString) as Map,
      );
      auth = Auth.fromJson(json);
    }
  }

  void reinitUser({bool gotToHome = true}) {
    apiController.clearAll();
    favouritesController.clearFavourites();
    historyController.clearHistory();
    secondaryPassword = '';
    if (auth.isAuthenticated) {
      ///////
      historyController.getHistory();
      favouritesController.getFavourites();
      apiController.fetchSources();
      /////
      if (gotToHome) {
        uiController.navController.select(0);
      }
    }
  }

  Future<bool> login({bool newUser = true}) async {
    if (auth.username.isEmpty || auth.password.isEmpty) {
      auth = auth.copyWith(
        status: false,
        errorMessage: 'Username and password cannot be empty',
      );
      return false;
    }

    isLoading = true;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await client.login(auth).then((authResponse) async {
      auth = authResponse;
      await saveAuth();
    }).catchError((error) {
      print('Login failed: $error');
      auth = auth.copyWith(
        status: false,
        errorMessage: 'Login failed: $error',
      );
    });

    serverController.connectWebSocket();
    isLoading = false;
    if (newUser) {
      reinitUser();
    }
    return auth.isAuthenticated;
  }

  Future<bool> register(GlobalKey<TextFieldEditorState> usernameFieldKey) async {
    if (auth.username.isEmpty || auth.password.isEmpty || secondaryPassword.isEmpty) {
      auth = auth.copyWith(
        status: false,
        errorMessage: 'Username, Password and Password Confirmation cannot be empty',
      );
      return false;
    }

    if (auth.password != secondaryPassword) {
      auth = auth.copyWith(
        status: false,
        errorMessage: 'Passwords do not match',
      );
      return false;
    }

    isLoading = true;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await client.register(auth).then((authResponse) async {
      if (authResponse.errorMessage.isNotEmpty && authResponse.errorMessage == 'Username already exists') {
        usernameFieldKey.currentState?.errorText = authResponse.errorMessage;
        authResponse = authResponse.copyWith(status: false, errorMessage: '');
      }
      auth = authResponse;
      await saveAuth();
    }).catchError((error) {
      throw Exception('Registration failed: $error');
    });
    isLoading = false;
    reinitUser();
    return auth.isAuthenticated;
  }

  Future<bool> changePassword() async {
    if (auth.password.isEmpty) {
      auth = auth.copyWith(
        status: false,
        errorMessage: 'New password cannot be empty',
      );
      return false;
    }

    isLoading = true;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await client.resetPassword(auth).then((authResponse) async {
      auth = authResponse.isAuthenticated ? authResponse.copyWith(errorMessage: 'Password Updated') : authResponse;
      await saveAuth();
    }).catchError((error) {
      throw Exception('Change password failed: $error');
    });
    isLoading = false;

    if (auth.isAuthenticated) {
      reinitUser(gotToHome: false);
    }
    return auth.isAuthenticated;
  }

  void clearFields() {
    auth = auth.clear();
    secondaryPassword = '';
  }

  void logout() async {
    auth = auth.clear();
    SharedPreferences.getInstance().then((prefs) => prefs.remove('auth'));

    uiController.setPage(0);
    serverController.endWsConnection();
  }
}
