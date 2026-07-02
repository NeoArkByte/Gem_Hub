// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_all_jobs_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminAllJobsViewModel)
final adminAllJobsViewModelProvider = AdminAllJobsViewModelProvider._();

final class AdminAllJobsViewModelProvider
    extends $AsyncNotifierProvider<AdminAllJobsViewModel, List<Job>> {
  AdminAllJobsViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'adminAllJobsViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$adminAllJobsViewModelHash();

  @$internal
  @override
  AdminAllJobsViewModel create() => AdminAllJobsViewModel();
}

String _$adminAllJobsViewModelHash() =>
    r'2c966be91d97e79d16dfe8b7109c4bd99e65fd83';

abstract class _$AdminAllJobsViewModel extends $AsyncNotifier<List<Job>> {
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
