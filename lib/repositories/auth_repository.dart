import 'package:shared_preferences/shared_preferences.dart';
import 'package:sipcot/model/user_model.dart';

class AuthRepository {
  static const _userKey = 'current_user';

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.email);
  }

  Future<UserModel?> getUserModel() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_userKey);
    if (email != null) {
      return UserModel(email: email);
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
