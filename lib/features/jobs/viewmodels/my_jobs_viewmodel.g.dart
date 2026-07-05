// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_jobs_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyJobsViewModel)
final myJobsViewModelProvider = MyJobsViewModelProvider._();

final class MyJobsViewModelProvider
    extends $AsyncNotifierProvider<MyJobsViewModel, List<Job>> {
  MyJobsViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'myJobsViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$myJobsViewModelHash();

  @$internal
  @override
  MyJobsViewModel create() => MyJobsViewModel();
}

String _$myJobsViewModelHash() => r'73d2d5a4e440aa620fcff237eff11bf432a935a7';

abstract class _$MyJobsViewModel extends $AsyncNotifier<List<Job>> {
  FutureOr<List<Job>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Job>>, List<Job>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Job>>, List<Job>>,
        AsyncValue<List<Job>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
