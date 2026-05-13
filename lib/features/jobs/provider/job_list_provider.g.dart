// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pendingJobs)
final pendingJobsProvider = PendingJobsProvider._();

final class PendingJobsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Job>>,
          List<Job>,
          FutureOr<List<Job>>
        >
    with $FutureModifier<List<Job>>, $FutureProvider<List<Job>> {
  PendingJobsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingJobsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingJobsHash();

  @$internal
  @override
  $FutureProviderElement<List<Job>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Job>> create(Ref ref) {
    return pendingJobs(ref);
  }
}

String _$pendingJobsHash() => r'229ba2691a4c8914b552e6d9e76f98d559013832';

@ProviderFor(approvedJobs)
final approvedJobsProvider = ApprovedJobsProvider._();

final class ApprovedJobsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Job>>,
          List<Job>,
          FutureOr<List<Job>>
        >
    with $FutureModifier<List<Job>>, $FutureProvider<List<Job>> {
  ApprovedJobsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'approvedJobsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$approvedJobsHash();

  @$internal
  @override
  $FutureProviderElement<List<Job>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Job>> create(Ref ref) {
    return approvedJobs(ref);
  }
}

String _$approvedJobsHash() => r'087f6c84a9dfb3028d0bbffeac6bb590c8626f0e';

@ProviderFor(latestApprovedJobs)
final latestApprovedJobsProvider = LatestApprovedJobsProvider._();

final class LatestApprovedJobsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Job>>,
          List<Job>,
          FutureOr<List<Job>>
        >
    with $FutureModifier<List<Job>>, $FutureProvider<List<Job>> {
  LatestApprovedJobsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestApprovedJobsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestApprovedJobsHash();

  @$internal
  @override
  $FutureProviderElement<List<Job>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Job>> create(Ref ref) {
    return latestApprovedJobs(ref);
  }
}

String _$latestApprovedJobsHash() =>
    r'b073697ad1d7785158d37382f278a00be9bd0d19';
