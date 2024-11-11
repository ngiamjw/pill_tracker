import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveDataEmail(String email) async {
  final prefs = await SharedPreferences.getInstance();

  // Save a single string
  await prefs.setString('user_email', email);
}

Future<void> saveRequestedUsers(List<String> users) async {
  final prefs = await SharedPreferences.getInstance();

  // Save a single string
  await prefs.setStringList('requested_users', users);
}

Future<void> addUserToRequestedUsers(String newUser) async {
  final prefs = await SharedPreferences.getInstance();

  // Retrieve the current list of users (returns null if not set)
  List<String> users = prefs.getStringList('requested_users') ?? [];

  // Append the new user to the list
  users.add(newUser);

  // Save the updated list back to SharedPreferences
  await prefs.setStringList('requested_users', users);
}

Future<String?> getEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_email');
}

Future<List<String>?> getUsers() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('requested_users');
}

Future<void> clearAllData() async {
  final prefs = await SharedPreferences.getInstance();

  // Clear all data
  await prefs.clear();
}
