import 'dart:io';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService extends GetxService {
  final _client = Supabase.instance.client;

  final String _bucketName = 'Foto Profile'; 

  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      // 1. path file di Supabase. 
      final String path = '$userId.jpg';

      // 2. Upload file
      await _client.storage.from(_bucketName).upload(
            path,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, 
            ),
          );

      // 3. Dapatkan URL publik dari file yang baru di-upload
      final String publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(path);

      final String cacheBustedUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      return cacheBustedUrl;  
          
    } catch (e) {
      print("Error uploading to Supabase: $e");
      rethrow;
    }
  }
}