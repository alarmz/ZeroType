import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:zero_type/features/model_config/domain/entities/ai_provider.dart';

abstract class ModelConfigRepository {
  Future<ProvidersConfig> loadProvidersConfig();

  Future<String?> getSelectedSpeechProviderId();
  Future<void> saveSelectedSpeechProviderId(String providerId);

  Future<String?> getSelectedSpeechModelId(String providerId);
  Future<void> saveSelectedSpeechModelId(String providerId, String modelId);

  Future<String?> getSpeechApiKey(String providerId);
  Future<void> saveSpeechApiKey(String providerId, String apiKey);

  Future<String?> getCustomEndpoint(String providerId);
  Future<void> saveCustomEndpoint(String providerId, String endpoint);

  /// Cached model list fetched from a dynamic provider's /v1/models endpoint.
  /// Empty list when nothing has been fetched yet.
  Future<List<AiModel>> getCachedModels(String providerId);
  Future<void> saveCachedModels(String providerId, List<AiModel> models);
}
