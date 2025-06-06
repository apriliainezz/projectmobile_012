import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsiah/database/database_helper.dart';

class SessionService {
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLoginTime = 'login_time';

  static User? _currentUser;

  // Initialize session service
  static Future<void> init() async {
    await DatabaseHelper.initDatabase();
    await _loadSession();
  }

  // Register new user
  static Future<SessionResult> registerToDatabase(
    String username,
    String password,
  ) async {
    try {
      print('SessionService: Attempting to register $username');

      if (username.isEmpty || password.isEmpty) {
        return SessionResult(
          success: false,
          message: 'Username dan password wajib diisi',
        );
      }

      if (password.length < 6) {
        return SessionResult(
          success: false,
          message: 'Password minimal 6 karakter',
        );
      }

      // Check existing users before registration
      final allUsers = DatabaseHelper.getAllUsers();
      print(
        'Existing users before registration: ${allUsers.map((u) => u.username).toList()}',
      );

      final user = await DatabaseHelper.registerUser(username, password);

      if (user == null) {
        print('Registration failed: Username already exists');
        return SessionResult(
          success: false,
          message: 'Username sudah terdaftar',
        );
      }

      print('Registration successful for user: ${user.username}');

      return SessionResult(
        success: true,
        message: 'Registrasi berhasil',
        user: user,
      );
    } catch (e) {
      print('Error in register: $e');
      return SessionResult(
        success: false,
        message: 'Terjadi kesalahan saat registrasi',
      );
    }
  }

  // Login user
  static Future<SessionResult> login(String username, String password) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        return SessionResult(
          success: false,
          message: 'Username dan password wajib diisi',
        );
      }

      final user = await DatabaseHelper.loginUser(username, password);

      if (user == null) {
        return SessionResult(
          success: false,
          message: 'Username atau password salah',
        );
      }

      await _createSession(user);

      return SessionResult(
        success: true,
        message: 'Login berhasil',
        user: user,
      );
    } catch (e) {
      return SessionResult(
        success: false,
        message: 'Terjadi kesalahan saat login',
      );
    }
  }

  // Create simple session
  static Future<void> _createSession(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyUsername, user.username);
    await prefs.setInt(_keyLoginTime, DateTime.now().millisecondsSinceEpoch);

    _currentUser = user;
  }

  // Load session from storage
  static Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (!isLoggedIn) {
      _currentUser = null;
      return;
    }

    try {
      final userId = prefs.getString(_keyUserId);

      if (userId == null) {
        await logout();
        return;
      }

      // Load user data from database
      final user = await DatabaseHelper.getUserById(userId);

      if (user != null) {
        _currentUser = user;
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyLoginTime);

    _currentUser = null;
  }

  // Check if user is logged in
  static bool get isLoggedIn => _currentUser != null;

  // Get current user
  static User? get currentUser => _currentUser;

  // Get current user ID
  static String? get currentUserId => _currentUser?.id;

  // Get current username
  static String? get currentUsername => _currentUser?.username;

  // Get current user full name
  static String? get currentFullName => _currentUser?.fullName;

  // Get session info
  static Future<SessionInfo?> getSessionInfo() async {
    if (!isLoggedIn) return null;

    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getInt(_keyLoginTime) ?? 0;

    return SessionInfo(
      user: _currentUser!,
      loginTime: DateTime.fromMillisecondsSinceEpoch(loginTime),
    );
  }

  // Update user profile
  static Future<bool> updateUserProfile(String newUsername) async {
    if (!isLoggedIn || _currentUser == null) return false;

    try {
      _currentUser!.username = newUsername;
      await _currentUser!.save();

      // Update session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUsername, newUsername);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update user full name
  static Future<bool> updateUserFullName(String newFullName) async {
    if (!isLoggedIn || _currentUser == null) return false;

    try {
      final success = await DatabaseHelper.updateUserFullName(
        _currentUser!.id,
        newFullName,
      );

      if (success) {
        // Update the current user object
        _currentUser!.fullName = newFullName;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update user profile image
  static Future<bool> updateUserProfileImage(String imagePath) async {
    if (!isLoggedIn || _currentUser == null) return false;

    try {
      final success = await DatabaseHelper.updateUserProfileImage(
        _currentUser!.id,
        imagePath,
      );

      if (success) {
        // Update the current user object
        _currentUser!.profileImagePath = imagePath;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Remove user profile image
  static Future<bool> removeUserProfileImage() async {
    if (!isLoggedIn || _currentUser == null) return false;

    try {
      final success = await DatabaseHelper.updateUserProfileImage(
        _currentUser!.id,
        '',
      );

      if (success) {
        // Update the current user object
        _currentUser!.profileImagePath = null;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Add method to clear all data for testing
  static Future<void> clearAllDataForTesting() async {
    await DatabaseHelper.clearUsersForTesting();
    await logout();
    print('All data cleared for testing');
  }
}

// Result class for login/register operations
class SessionResult {
  final bool success;
  final String message;
  final User? user;

  SessionResult({required this.success, required this.message, this.user});
}

// Simplified session info class
class SessionInfo {
  final User user;
  final DateTime loginTime;

  SessionInfo({required this.user, required this.loginTime});

  Duration get sessionDuration => DateTime.now().difference(loginTime);
}
