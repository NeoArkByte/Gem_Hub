// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CertificateViewModel)
final certificateViewModelProvider = CertificateViewModelFamily._();

final class CertificateViewModelProvider
    extends $AsyncNotifierProvider<CertificateViewModel, String> {
  CertificateViewModelProvider._({
    required CertificateViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'certificateViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$certificateViewModelHash();

  @override
  String toString() {
    return r'certificateViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CertificateViewModel create() => CertificateViewModel();

  @override
  bool operator ==(Object other) {
    return other is CertificateViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$certificateViewModelHash() =>
    r'c8503cf795bd9074c1935e0590428c5eb4392860';

final class CertificateViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          CertificateViewModel,
          AsyncValue<String>,
          String,
          FutureOr<String>,
          String
        > {
  CertificateViewModelFamily._()
    : super(
        retry: null,
        name: r'certificateViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CertificateViewModelProvider call(String path) =>
      CertificateViewModelProvider._(argument: path, from: this);

  @override
  String toString() => r'certificateViewModelProvider';
}

abstract class _$CertificateViewModel extends $AsyncNotifier<String> {
  late final _$args = ref.$arg as String;
  String get path => _$args;

  FutureOr<String> build(String path);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
