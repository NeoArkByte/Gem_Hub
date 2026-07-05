// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_job_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PostJobViewModel)
final postJobViewModelProvider = PostJobViewModelProvider._();

final class PostJobViewModelProvider
    extends $AsyncNotifierProvider<PostJobViewModel, void> {
  PostJobViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'postJobViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postJobViewModelHash();

  @$internal
  @override
  PostJobViewModel create() => PostJobViewModel();
}

String _$postJobViewModelHash() => r'c50aba2470be3ea710b35af31fcf82dbc17e7ec7';

abstract class _$PostJobViewModel extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
