import 'dart:io';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService extends GetxService {
  final _client = Supabase.instance.client;

  final String _profileBucketName = 'Foto Profile';
  final String _voucherBucketName = 'foto vouchers';

  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      // 1. path file di Supabase. 
      final String path = '$userId.jpg';

      // 2. Upload file
      await _client.storage.from(_profileBucketName).upload(
            path,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, 
            ),
          );

      // 3. Dapatkan URL publik dari file yang baru di-upload
      final String publicUrl = _client.storage
          .from(_profileBucketName)
          .getPublicUrl(path);

      final String cacheBustedUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      return cacheBustedUrl;  
          
    } catch (e) {
      print("Error uploading to Supabase: $e");
      rethrow;
    }
  }

  /// Upload voucher image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String?> uploadVoucherImage({
    required File imageFile,
    required String voucherId,
  }) async {
    try {
      print("=== SUPABASE: Upload voucher image started ===");
      print("Image path: ${imageFile.path}");
      print("Voucher ID: $voucherId");
      print("Bucket name: $_voucherBucketName");

      // Check if file exists
      final fileExists = await imageFile.exists();
      print("File exists: $fileExists");
      if (!fileExists) {
        print("ERROR: Image file does not exist!");
        return null;
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${voucherId}_$timestamp.jpg';
      
      print("Uploading to: $_voucherBucketName/$fileName");

      // Upload to Supabase Storage bucket 'foto vouchers'
      final uploadResponse = await _client.storage
          .from(_voucherBucketName)
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      print("Upload response: $uploadResponse");
      print("Upload successful!");

      // Get public URL with cache buster
      final publicUrl = _client.storage
          .from(_voucherBucketName)
          .getPublicUrl(fileName);

      final cacheBustedUrl = '$publicUrl?t=$timestamp';
      
      print("Public URL: $cacheBustedUrl");
      return cacheBustedUrl;
    } catch (e, stackTrace) {
      print("=== SUPABASE ERROR: $e ===");
      print("Stack trace: $stackTrace");
      return null;
    }
  }

  /// Delete voucher image from Supabase Storage
  Future<bool> deleteVoucherImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty || !imageUrl.contains('supabase')) {
        return false;
      }

      // Extract filename from URL (remove query params)
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments.last;

      print("Deleting voucher image: $fileName");

      await _client.storage
          .from(_voucherBucketName)
          .remove([fileName]);

      print("Voucher image deleted successfully");
      return true;
    } catch (e) {
      print("Error deleting voucher image: $e");
      return false;
    }
  }
}