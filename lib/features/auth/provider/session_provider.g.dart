// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(session)
final sessionProvider = SessionProvider._();

final class SessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthenticatedUser?>,
          AuthenticatedUser?,
          Stream<AuthenticatedUser?>
        >
    with
        $FutureModifier<AuthenticatedUser?>,
        $StreamProvider<AuthenticatedUser?> {
  SessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionHash();

  @$internal
  @override
  $StreamProviderElement<AuthenticatedUser?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AuthenticatedUser?> create(Ref ref) {
    return session(ref);
  }
}

String _$sessionHash() => r'22babe9d35f878c17ea7ee2a6d46293851d9484b';
