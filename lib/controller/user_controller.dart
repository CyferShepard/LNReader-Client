import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/auth.dart';
import 'package:light_novel_reader_client/models/user.dart';

class UserController extends GetxController {
  final _users = Rx<List<User>>(<User>[]);
  List<User> get users => _users.value;
  set users(List<User> value) => _users.value = value;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  Future<void> getUsers() async {
    users = await client.getUsers();
  }

  Future<bool> resetUserPassword(String username, String password) async {
    try {
      isLoading = true;
      Auth user = Auth(username: username, password: password);
      user = await client.resetPassword(user, username: username);
      isLoading = false;
      return user.status;
    } catch (e) {
      print('Failed to reset password: $e');
      isLoading = false;
      return false;
    }
  }
}
