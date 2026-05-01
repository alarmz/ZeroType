// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_config_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(providersConfig)
final providersConfigProvider = ProvidersConfigProvider._();

final class ProvidersConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProvidersConfig>,
          ProvidersConfig,
          FutureOr<ProvidersConfig>
        >
    with $FutureModifier<ProvidersConfig>, $FutureProvider<ProvidersConfig> {
  ProvidersConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providersConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providersConfigHash();

  @$internal
  @override
  $FutureProviderElement<ProvidersConfig> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProvidersConfig> create(Ref ref) {
    return providersConfig(ref);
  }
}

String _$providersConfigHash() => r'e2ff73813b840311cdc81bbe6411d20be6700000';

@ProviderFor(SpeechProviderController)
final speechProviderControllerProvider = SpeechProviderControllerProvider._();

final class SpeechProviderControllerProvider
    extends
        $AsyncNotifierProvider<
          SpeechProviderController,
          ({
            String? apiKey,
            String? customEndpoint,
            String? modelId,
            String? providerId,
          })
        > {
  SpeechProviderControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'speechProviderControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$speechProviderControllerHash();

  @$internal
  @override
  SpeechProviderController create() => SpeechProviderController();
}

String _$speechProviderControllerHash() =>
    r'9f533aaad184789dbd3efc8467e110a97e9f6cea';

abstract class _$SpeechProviderController
    extends
        $AsyncNotifier<
          ({
            String? apiKey,
            String? customEndpoint,
            String? modelId,
            String? providerId,
          })
        > {
  FutureOr<
    ({
      String? apiKey,
      String? customEndpoint,
      String? modelId,
      String? providerId,
    })
  >
  build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<
                ({
                  String? apiKey,
                  String? customEndpoint,
                  String? modelId,
                  String? providerId,
                })
              >,
              ({
                String? apiKey,
                String? customEndpoint,
                String? modelId,
                String? providerId,
              })
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<
                  ({
                    String? apiKey,
                    String? customEndpoint,
                    String? modelId,
                    String? providerId,
                  })
                >,
                ({
                  String? apiKey,
                  String? customEndpoint,
                  String? modelId,
                  String? providerId,
                })
              >,
              AsyncValue<
                ({
                  String? apiKey,
                  String? customEndpoint,
                  String? modelId,
                  String? providerId,
                })
              >,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Holds the dynamically-fetched model list for an OpenAI-compatible provider
/// (currently used by `litellm`). Returns the cached list immediately on
/// build; call `refresh()` to hit `/v1/models` and update the cache.

@ProviderFor(DynamicModelsController)
final dynamicModelsControllerProvider = DynamicModelsControllerFamily._();

/// Holds the dynamically-fetched model list for an OpenAI-compatible provider
/// (currently used by `litellm`). Returns the cached list immediately on
/// build; call `refresh()` to hit `/v1/models` and update the cache.
final class DynamicModelsControllerProvider
    extends $AsyncNotifierProvider<DynamicModelsController, List<AiModel>> {
  /// Holds the dynamically-fetched model list for an OpenAI-compatible provider
  /// (currently used by `litellm`). Returns the cached list immediately on
  /// build; call `refresh()` to hit `/v1/models` and update the cache.
  DynamicModelsControllerProvider._({
    required DynamicModelsControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dynamicModelsControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dynamicModelsControllerHash();

  @override
  String toString() {
    return r'dynamicModelsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DynamicModelsController create() => DynamicModelsController();

  @override
  bool operator ==(Object other) {
    return other is DynamicModelsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dynamicModelsControllerHash() =>
    r'8070a60946d83a5b1a6876a585a70c32ef4b90a9';

/// Holds the dynamically-fetched model list for an OpenAI-compatible provider
/// (currently used by `litellm`). Returns the cached list immediately on
/// build; call `refresh()` to hit `/v1/models` and update the cache.

final class DynamicModelsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          DynamicModelsController,
          AsyncValue<List<AiModel>>,
          List<AiModel>,
          FutureOr<List<AiModel>>,
          String
        > {
  DynamicModelsControllerFamily._()
    : super(
        retry: null,
        name: r'dynamicModelsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Holds the dynamically-fetched model list for an OpenAI-compatible provider
  /// (currently used by `litellm`). Returns the cached list immediately on
  /// build; call `refresh()` to hit `/v1/models` and update the cache.

  DynamicModelsControllerProvider call(String providerId) =>
      DynamicModelsControllerProvider._(argument: providerId, from: this);

  @override
  String toString() => r'dynamicModelsControllerProvider';
}

/// Holds the dynamically-fetched model list for an OpenAI-compatible provider
/// (currently used by `litellm`). Returns the cached list immediately on
/// build; call `refresh()` to hit `/v1/models` and update the cache.

abstract class _$DynamicModelsController extends $AsyncNotifier<List<AiModel>> {
  late final _$args = ref.$arg as String;
  String get providerId => _$args;

  FutureOr<List<AiModel>> build(String providerId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<AiModel>>, List<AiModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AiModel>>, List<AiModel>>,
              AsyncValue<List<AiModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
