// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileViewModel)
final profileViewModelProvider = ProfileViewModelProvider._();

final class ProfileViewModelProvider
    extends
        $NotifierProvider<ProfileViewModel, AsyncValue<AuthenticatedUser?>> {
  ProfileViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileViewModelHash();

  @$internal
  @override
  ProfileViewModel create() => ProfileViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AuthenticatedUser?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<AuthenticatedUser?>>(
        value,
      ),
    );
  }
}

String _$profileViewModelHash() => r'adea2a76f3823ba1e72758e10cd10519d264b109';

abstract class _$ProfileViewModel
    extends $Notifier<AsyncValue<AuthenticatedUser?>> {
  AsyncValue<AuthenticatedUser?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AuthenticatedUser?>,
              AsyncValue<AuthenticatedUser?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AuthenticatedUser?>,
                AsyncValue<AuthenticatedUser?>
              >,
              AsyncValue<AuthenticatedUser?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
