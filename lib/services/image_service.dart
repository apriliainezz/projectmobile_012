import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image == null) return null;
    return File(image.path);
  }

  // Pick image from camera
  static Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image == null) return null;
    return File(image.path);
  }

  // Save image to app directory
  static Future<String?> saveProfileImage(File imageFile, String userId) async {
    try {
      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${directory.path}/profiles');

      // Create directory if it doesn't exist
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // Create a unique filename with user ID
      final filename = 'profile_$userId${path.extension(imageFile.path)}';
      final savedImagePath = '${profileDir.path}/$filename';

      // Copy the image to the new path
      await imageFile.copy(savedImagePath);

      return savedImagePath;
    } catch (e) {
      debugPrint('Error saving profile image: $e');
      return null;
    }
  }

  // Delete profile image
  static Future<bool> deleteProfileImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
      return false;
    }
  }
}
