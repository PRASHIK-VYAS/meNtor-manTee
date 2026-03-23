import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// UserProvider - Manages user data using Provider pattern
/// All data is stored in memory (no database, no API)
class UserProvider with ChangeNotifier {
  // List to store all users in memory
  List<UserModel> _users = [];

  // Getter to access users list
  List<UserModel> get users => List.unmodifiable(_users);

  // Get users by role
  List<UserModel> getUsersByRole(String role) {
    return _users.where((user) => user.role == role).toList();
  }

  // Get user by ID
  UserModel? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Initialize with mock data
  void initializeMockData() {
    _users = [
      UserModel(
        id: '1',
        name: 'Dr. Rajesh Kumar',
        email: 'rajesh.kumar@cse.edu',
        role: 'mentor',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserModel(
        id: '2',
        name: 'Prof. Priya Sharma',
        email: 'priya.sharma@cse.edu',
        role: 'mentor',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      UserModel(
        id: '3',
        name: 'Amit Patel',
        email: 'amit.patel@student.edu',
        role: 'mentee',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      UserModel(
        id: '4',
        name: 'Sneha Reddy',
        email: 'sneha.reddy@student.edu',
        role: 'mentee',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      UserModel(
        id: '5',
        name: 'Dr. Vikram Singh',
        email: 'vikram.singh@cse.edu',
        role: 'mentor',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
    notifyListeners(); // Notify all listeners that data has changed
  }

  // Add a new user
  void addUser(UserModel user) {
    _users.add(user);
    notifyListeners(); // Notify UI to rebuild
  }

  // Update an existing user
  void updateUser(UserModel updatedUser) {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners(); // Notify UI to rebuild
    }
  }

  // Delete a user
  void deleteUser(String id) {
    _users.removeWhere((user) => user.id == id);
    notifyListeners(); // Notify UI to rebuild
  }

  // Clear all users (useful for testing)
  void clearAllUsers() {
    _users.clear();
    notifyListeners();
  }
}
