import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'backup_repository.dart';

part 'backup_repository_provider.g.dart';

@riverpod
BackupRepository backupRepository(Ref ref) {
  return BackupRepository();
}