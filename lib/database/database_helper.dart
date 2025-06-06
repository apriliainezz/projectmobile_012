import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';

part 'database_helper.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String username;

  @HiveField(2)
  late String hashedPassword;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  String? profileImagePath;

  @HiveField(5)
  late String fullName;

  User({
    required this.id,
    required this.username,
    required this.hashedPassword,
    required this.createdAt,
    required this.fullName,
    this.profileImagePath,
  });
}

@HiveType(typeId: 1)
class MovieLove extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String userId;

  @HiveField(2)
  late String movieId;

  @HiveField(3)
  late String movieTitle; // Add movieTitle field

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late String imageUrl; // Add imageUrl field

  MovieLove({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.movieTitle, // Update constructor
    required this.createdAt,
    required this.imageUrl, // Add imageUrl to constructor
  });
}

@HiveType(typeId: 2)
class MovieRental extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String movieId;

  @HiveField(2)
  late String userId;

  @HiveField(3)
  late String statusPembelian;

  @HiveField(4)
  late double harga;

  @HiveField(5)
  late DateTime rentalDate;

  @HiveField(6)
  late DateTime expiryDate;

  @HiveField(7)
  late String imageUrl;

  @HiveField(8)
  late String title;

  @HiveField(9)
  late String synopsis;

  @HiveField(10)
  late String genre;

  @HiveField(11)
  late String currency;

  @HiveField(12)
  late String paymentTime;

  MovieRental({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.statusPembelian,
    required this.harga,
    required this.rentalDate,
    required this.expiryDate,
    required this.imageUrl,
    required this.title,
    required this.synopsis,
    required this.genre,
    required this.currency,
    required this.paymentTime,
  });
}

class DatabaseHelper {
  static const String _userBoxName = 'users';
  static const String _movieLoveBoxName = 'movie_loves';
  static const String _movieRentalBoxName = 'movie_rentals';

  static late Box<User> _userBox;
  static late Box<MovieLove> _movieLoveBox;
  static late Box<MovieRental> _movieRentalBox;

  static Future<void> initDatabase() async {
    try {
      print('Initializing database...');

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(MovieLoveAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(MovieRentalAdapter());
      }

      try {
        // Open boxes
        _userBox = await Hive.openBox<User>(_userBoxName);
        _movieLoveBox = await Hive.openBox<MovieLove>(_movieLoveBoxName);
        _movieRentalBox = await Hive.openBox<MovieRental>(_movieRentalBoxName);
      } catch (e) {
        print('Error opening boxes, clearing corrupted data: $e');
        // Jika ada error saat membuka box (misalnya karena struktur berubah),
        // hapus box lama dan buat ulang
        await Hive.deleteBoxFromDisk(_movieLoveBoxName);
        await Hive.deleteBoxFromDisk(_userBoxName);
        await Hive.deleteBoxFromDisk(_movieRentalBoxName);

        // Buka box lagi setelah dihapus
        _userBox = await Hive.openBox<User>(_userBoxName);
        _movieLoveBox = await Hive.openBox<MovieLove>(_movieLoveBoxName);
        _movieRentalBox = await Hive.openBox<MovieRental>(_movieRentalBoxName);
      }

      print('Database initialized successfully');
      print('Users box length: ${_userBox.length}');
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<User?> registerUser(String username, String password) async {
    try {
      print('Attempting to register user: $username');
      print('Total users in database: ${_userBox.length}');

      // List all existing usernames for debugging
      final allUsernames =
          _userBox.values.map((user) => user.username).toList();
      print('Existing usernames: $allUsernames');

      // Check if username already exists - fix the logic here
      final existingUser = _userBox.values
          .where(
            (user) => user.username.toLowerCase() == username.toLowerCase(),
          )
          .firstOrNull;

      if (existingUser != null) {
        print('Username $username already exists');
        return null; // Username already taken
      }

      print('Creating new user...');
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        hashedPassword: _hashPassword(password),
        createdAt: DateTime.now(),
        fullName: username, // Set fullName to username initially
      );

      await _userBox.put(user.id, user);
      print('User created successfully with ID: ${user.id}');
      return user;
    } catch (e) {
      print('Error in registerUser: $e');
      return null;
    }
  }

  // Add method to clear database for testing
  static Future<void> clearUsersForTesting() async {
    await _userBox.clear();
    print('All users cleared from database');
  }

  // Add method to list all users for debugging
  static List<User> getAllUsers() {
    return _userBox.values.toList();
  }

  static Future<User?> loginUser(String username, String password) async {
    try {
      print('Attempting to login user: $username');
      print('Total users in database: ${_userBox.length}');

      // List all existing usernames for debugging
      final allUsernames =
          _userBox.values.map((user) => user.username).toList();
      print('Existing usernames: $allUsernames');

      final hashedPassword = _hashPassword(password);

      // Use case-insensitive username matching to match registration behavior
      final user = _userBox.values
          .where(
            (user) =>
                user.username.toLowerCase() == username.toLowerCase() &&
                user.hashedPassword == hashedPassword,
          )
          .firstOrNull;

      if (user != null) {
        print('Login successful for user: ${user.username}');
      } else {
        print('Login failed for user: $username');
      }

      return user;
    } catch (e) {
      print('Error in loginUser: $e');
      return null;
    }
  }

  static Future<User?> getUserById(String userId) async {
    return _userBox.get(userId);
  }

  static Future<bool> addMovieLove(
    String userId,
    String movieId,
    String movieTitle,
    String imageUrl,
  ) async {
    try {
      final existingLove = _movieLoveBox.values
          .where((love) => love.userId == userId && love.movieId == movieId)
          .firstOrNull;

      if (existingLove != null) {
        return false;
      }

      final movieLove = MovieLove(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        movieId: movieId,
        movieTitle: movieTitle, // Store movieTitle
        createdAt: DateTime.now(),
        imageUrl: imageUrl, // Store imageUrl
      );

      await _movieLoveBox.put(movieLove.id, movieLove);
      return true;
    } catch (e) {
      print('Error adding movie love: $e');
      return false;
    }
  }

  static Future<bool> removeMovieLove(String userId, String movieId) async {
    try {
      final movieLove = _movieLoveBox.values
          .where((love) => love.userId == userId && love.movieId == movieId)
          .firstOrNull;

      if (movieLove != null) {
        await movieLove.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static List<MovieLove> getUserLovedMovies(String userId) {
    try {
      return _movieLoveBox.values
          .where((love) => love.userId == userId)
          .toList();
    } catch (e) {
      print('Error getting user loved movies: $e');
      // Jika ada error, hapus data yang corrupt dan return list kosong
      _clearCorruptedMovieLoveData();
      return [];
    }
  }

  static void _clearCorruptedMovieLoveData() async {
    try {
      await _movieLoveBox.clear();
      print('Cleared corrupted movie love data');
    } catch (e) {
      print('Error clearing corrupted data: $e');
    }
  }

  static bool isMovieLoved(String userId, String movieId) {
    return _movieLoveBox.values.any(
      (love) => love.userId == userId && love.movieId == movieId,
    );
  }

  static Future<MovieRental?> rentMovie(
    String movieId,
    String userId,
    double harga, {
    int rentalDays = 7,
    int rentalHours = 0,
    required String imageUrl,
    required String title,
    required String synopsis,
    required String genre,
    required String currency,
    required String paymentTime,
  }) async {
    try {
      // Check if user already has an active rental for this movie
      final existingRental = _movieRentalBox.values
          .where((rental) =>
              rental.userId == userId &&
              rental.movieId == movieId &&
              rental.expiryDate.isAfter(DateTime.now()))
          .firstOrNull;

      if (existingRental != null) {
        // Return null to indicate rental already exists
        return null;
      }

      // Calculate expiry date based on hours or days
      final Duration rentalDuration = rentalHours > 0
          ? Duration(hours: rentalHours)
          : Duration(days: rentalDays);

      final rental = MovieRental(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        movieId: movieId,
        userId: userId,
        statusPembelian: 'active',
        harga: harga,
        rentalDate: DateTime.now(),
        expiryDate: DateTime.now().add(rentalDuration),
        imageUrl: imageUrl,
        title: title,
        synopsis: synopsis,
        genre: genre,
        currency: currency,
        paymentTime: paymentTime,
      );

      await _movieRentalBox.put(rental.id, rental);
      return rental;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateRentalStatus(
    String rentalId,
    String newStatus,
  ) async {
    try {
      final rental = _movieRentalBox.get(rentalId);
      if (rental != null) {
        rental.statusPembelian = newStatus;
        await rental.save();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static List<MovieRental> getUserRentals(String userId) {
    return _movieRentalBox.values
        .where((rental) => rental.userId == userId)
        .toList();
  }

  static List<MovieRental> getActiveRentals(String userId) {
    return _movieRentalBox.values
        .where(
          (rental) =>
              rental.userId == userId &&
              rental.statusPembelian == 'active' &&
              rental.expiryDate.isAfter(DateTime.now()),
        )
        .toList();
  }

  static bool isMovieRented(String userId, String movieId) {
    return _movieRentalBox.values.any(
      (rental) =>
          rental.userId == userId &&
          rental.movieId == movieId &&
          rental.expiryDate.isAfter(DateTime.now()),
    );
  }

  static Future<void> clearAllData() async {
    await _userBox.clear();
    await _movieLoveBox.clear();
    await _movieRentalBox.clear();
  }

  static Future<void> closeDatabase() async {
    await _userBox.close();
    await _movieLoveBox.close();
    await _movieRentalBox.close();
  }

  static Future<void> updateExpiredRentals() async {
    final now = DateTime.now();
    final expiredRentals = _movieRentalBox.values
        .where(
          (rental) =>
              rental.statusPembelian == 'active' &&
              rental.expiryDate.isBefore(now),
        )
        .toList();

    for (final rental in expiredRentals) {
      rental.statusPembelian = 'expired';
      await rental.save();
    }
  }

  // Update user profile image
  static Future<bool> updateUserProfileImage(
    String userId,
    String imagePath,
  ) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return false;

      // Delete previous profile image if exists
      if (user.profileImagePath != null && user.profileImagePath!.isNotEmpty) {
        final oldImageFile = File(user.profileImagePath!);
        if (await oldImageFile.exists()) {
          await oldImageFile.delete();
        }
      }

      // Update user with new profile image
      user.profileImagePath = imagePath;
      await user.save();

      return true;
    } catch (e) {
      print('Error updating profile image: $e');
      return false;
    }
  }

  // Method untuk reset semua data jika ada masalah struktur
  static Future<void> resetDatabase() async {
    try {
      await _userBox.clear();
      await _movieLoveBox.clear();
      await _movieRentalBox.clear();
      print('Database reset successfully');
    } catch (e) {
      print('Error resetting database: $e');
    }
  }

  // Update user full name
  static Future<bool> updateUserFullName(
      String userId, String newFullName) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return false;

      user.fullName = newFullName.trim();
      await user.save();

      return true;
    } catch (e) {
      print('Error updating full name: $e');
      return false;
    }
  }
}
