// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PendingJobsViewModel)
final pendingJobsViewModelProvider = PendingJobsViewModelProvider._();

final class PendingJobsViewModelProvider
    extends $AsyncNotifierProvider<PendingJobsViewModel, List<Job>> {
  PendingJobsViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingJobsViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingJobsViewModelHash();

  @$internal
  @override
  PendingJobsViewModel create() => PendingJobsViewModel();
}

String _$pendingJobsViewModelHash() =>
    r'07efa93c5014883b3993d3242a02e77f614025ba';

abstract class _$PendingJobsViewModel extends $AsyncNotifier<List<Job>> {
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
