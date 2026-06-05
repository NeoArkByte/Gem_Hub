// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BackupViewModel)
final backupViewModelProvider = BackupViewModelProvider._();

final class BackupViewModelProvider
    extends $NotifierProvider<BackupViewModel, BackupState> {
  BackupViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupViewModelHash();

  @$internal
  @override
  BackupViewModel create() => BackupViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupState>(value),
    );
  }
}

String _$backupViewModelHash() => r'799218ab3b7680e9b2c67e1f9ff44a8071ebd37c';

abstract class _$BackupViewModel extends $Notifier<BackupState> {
  BackupState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BackupState, BackupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BackupState, BackupState>,
              BackupState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
