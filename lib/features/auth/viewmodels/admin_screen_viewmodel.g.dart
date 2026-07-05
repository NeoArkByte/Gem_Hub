// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_screen_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminScreenViewModel)
final adminScreenViewModelProvider = AdminScreenViewModelProvider._();

final class AdminScreenViewModelProvider
    extends $AsyncNotifierProvider<AdminScreenViewModel, AdminScreenState> {
  AdminScreenViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'adminScreenViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$adminScreenViewModelHash();

  @$internal
  @override
  AdminScreenViewModel create() => AdminScreenViewModel();
}

String _$adminScreenViewModelHash() =>
    r'149e4dc035b47a74bdd694238640a3b8a06e6a39';

abstract class _$AdminScreenViewModel extends $AsyncNotifier<AdminScreenState> {
  FutureOr<AdminScreenState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AdminScreenState>, AdminScreenState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AdminScreenState>, AdminScreenState>,
        AsyncValue<AdminScreenState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
