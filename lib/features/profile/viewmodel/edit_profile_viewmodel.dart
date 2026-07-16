import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/models/auth/profile_model.dart';
import 'package:gemhub/data/repositories/profile/profile_repository.dart';
import 'package:gemhub/data/services/storage_service.dart';
import 'package:gemhub/features/auth/provider/session_provider.dart';

part 'edit_profile_viewmodel.g.dart';

@riverpod
class EditProfileViewModel extends _$EditProfileViewModel {
  @override
  bool build() => false;

  Future<bool> updateProfile({
    required ProfileUser originalProfile,
    required String username,
    required String email,
    required String phone,
    required String description,
    File? newAvatarFile,
  }) async {
    final sessionAsync = ref.read(sessionProvider);
    final currentUser = sessionAsync.value;

    if (currentUser?.supabaseUser == null) return false;

    final supabaseUid = currentUser!.supabaseUser!.id;

    state = true;
    final keepAliveLink = ref.keepAlive();

    try {
      final storageService = StorageService();

      
      String? finalAvatarUrl = originalProfile.avatarUrl;

      print('Original Profile: ${originalProfile.toMap()}');

      if (newAvatarFile != null) {
        finalAvatarUrl = await storageService.updateFile(
          bucket: 'listings',
          newFile: newAvatarFile,
          userId: supabaseUid,
          oldUrlOrPath: originalProfile.avatarUrl,
        );

      }

      final updatedProfile = originalProfile.copyWith(
        username: username.trim(),
        email: email.trim(),
        phone: phone.trim(),
        description: description.trim(),
        avatarUrl: finalAvatarUrl,
      );

      print('Updated Profile Object: ${finalAvatarUrl}');
      print('Updated Profile Object: ${newAvatarFile}');

      print('Updated Profile Payload: ${updatedProfile.toMap()}');

      final success = await ref.read(profileRepositoryProvider).updateProfile(updatedProfile);

      if (success) {
        ref.invalidate(sessionProvider);
      }

      state = false;
      keepAliveLink.close();
      return success;
    } catch (e) {
      state = false;
      keepAliveLink.close();
      return false;
    }
  }
}