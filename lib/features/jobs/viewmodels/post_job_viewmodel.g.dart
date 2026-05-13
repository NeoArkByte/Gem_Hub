part of 'post_job_viewmodel.dart';
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

String _$postJobViewModelHash() => r'907c876c21699c4446d52f4d1fea224f28bbfd7c';

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
