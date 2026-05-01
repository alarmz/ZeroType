import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:zero_type/core/services/app_logger.dart';

typedef TranscriptionResult = ({
  String text,
  int? inputTokens,
  int? outputTokens,
});

class SpeechRecognitionService {
  SpeechRecognitionService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<TranscriptionResult> transcribe({
    required String audioFilePath,
    required String apiKey,
    required String provider,
    required String model,
    required String prompt,
    String? customEndpoint,
  }) async {
    AppLogger.log('SpeechRecognition',
        'transcribe start: provider=$provider model=$model file=$audioFilePath endpoint=${customEndpoint ?? '(default)'}');

    switch (provider) {
      case 'openai':
        return _transcribeWithOpenAI(
          audioFilePath: audioFilePath,
          apiKey: apiKey,
          model: model,
          prompt: prompt,
          customEndpoint: customEndpoint,
        );
      case 'gemini':
        return _transcribeWithGemini(
          audioFilePath: audioFilePath,
          apiKey: apiKey,
          model: model,
          prompt: prompt,
          customEndpoint: customEndpoint,
        );
      case 'litellm':
        if (customEndpoint == null || customEndpoint.isEmpty) {
          throw Exception('LiteLLM 需要在「進階設定」中填寫 Proxy Base URL');
        }
        final base = _stripTrailingSlash(customEndpoint);
        // Whisper-style transcription models go to /v1/audio/transcriptions.
        // Everything else (Gemini, GPT-4o-audio, Claude, …) is treated as a
        // multimodal chat model and gets the audio embedded in a
        // /v1/chat/completions request — that's the only LiteLLM-supported
        // path that actually works for non-whisper backends.
        if (model.toLowerCase().contains('whisper')) {
          return _transcribeWithOpenAI(
            audioFilePath: audioFilePath,
            apiKey: apiKey,
            model: model,
            prompt: prompt,
            customEndpoint: '$base/v1/audio/transcriptions',
          );
        }
        return _transcribeWithChatCompletions(
          audioFilePath: audioFilePath,
          apiKey: apiKey,
          model: model,
          prompt: prompt,
          baseUrl: base,
        );
      default:
        throw Exception('不支援的語音辨識服務商：$provider');
    }
  }

  /// Fetches the model list from an OpenAI-compatible `/v1/models` endpoint
  /// (e.g. a LiteLLM proxy). Returns id+name records; callers map to UI
  /// entities. The `id` is what gets sent to the transcription endpoint.
  Future<List<({String id, String name})>> fetchAvailableModels({
    required String baseUrl,
    required String apiKey,
  }) async {
    final url = '${_stripTrailingSlash(baseUrl)}/v1/models';
    AppLogger.log('LiteLLM', 'GET $url');
    try {
      final response = await _dio.get<dynamic>(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
      );

      Map<String, dynamic>? body;
      if (response.data is Map<String, dynamic>) {
        body = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        body = jsonDecode(response.data as String) as Map<String, dynamic>;
      }
      final list = body?['data'] as List? ?? const [];
      final models = list
          .whereType<Map<String, dynamic>>()
          .map((m) {
            final id = m['id'] as String? ?? '';
            return (id: id, name: id);
          })
          .where((m) => m.id.isNotEmpty)
          .toList();
      AppLogger.log('LiteLLM',
          'fetched ${models.length} models from /v1/models');
      return models;
    } on DioException catch (e) {
      throw _wrapDioError('fetchAvailableModels GET $url', e);
    }
  }

  /// Multimodal transcription via the OpenAI-compatible `/v1/chat/completions`
  /// endpoint. Used by the LiteLLM provider for non-whisper models (Gemini,
  /// GPT-4o-audio, Claude with audio, etc.) — LiteLLM bridges the OpenAI
  /// `input_audio` content part to the backend's native audio API.
  Future<TranscriptionResult> _transcribeWithChatCompletions({
    required String audioFilePath,
    required String apiKey,
    required String model,
    required String prompt,
    required String baseUrl,
  }) async {
    final url = '$baseUrl/v1/chat/completions';
    final file = File(audioFilePath);
    if (!file.existsSync()) {
      throw Exception('找不到音檔：$audioFilePath');
    }
    final bytes = await file.readAsBytes();
    final base64Audio = base64Encode(bytes);

    final lower = audioFilePath.toLowerCase();
    final format = lower.endsWith('.m4a')
        ? 'm4a'
        : lower.endsWith('.mp3')
            ? 'mp3'
            : lower.endsWith('.wav')
                ? 'wav'
                : lower.endsWith('.ogg')
                    ? 'ogg'
                    : 'm4a';

    final finalPrompt =
        prompt.isEmpty ? 'Transcribe the speech in this audio.' : prompt;

    AppLogger.log('LiteLLM-chat',
        'POST $url model=$model format=$format bytes=${bytes.length}');

    Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        url,
        data: {
          'model': model,
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': finalPrompt},
                {
                  'type': 'input_audio',
                  'input_audio': {
                    'data': base64Audio,
                    'format': format,
                  },
                },
              ],
            },
          ],
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      throw _wrapDioError('LiteLLM chat POST $url', e);
    }

    Map<String, dynamic>? body;
    if (response.data is Map<String, dynamic>) {
      body = response.data as Map<String, dynamic>;
    } else if (response.data is String) {
      body = jsonDecode(response.data as String) as Map<String, dynamic>;
    }
    final choices = body?['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('LiteLLM 回應沒有 choices 欄位：${response.data}');
    }
    final message = (choices.first as Map<String, dynamic>)['message']
        as Map<String, dynamic>?;
    final content = message?['content'];
    final text = (content is String) ? content.trim() : '';

    final usage = body?['usage'] as Map<String, dynamic>?;
    final inputTokens = usage?['prompt_tokens'] as int?;
    final outputTokens = usage?['completion_tokens'] as int?;

    AppLogger.log('LiteLLM-chat',
        'success length=${text.length} tokens: in=$inputTokens out=$outputTokens');
    return (text: text, inputTokens: inputTokens, outputTokens: outputTokens);
  }

  static String _stripTrailingSlash(String s) =>
      s.replaceAll(RegExp(r'/+$'), '');

  /// Convert a DioException into a readable Exception with status, message,
  /// and a truncated response body. Also logs the full details so the file
  /// log retains everything useful for diagnosis.
  Exception _wrapDioError(String context, DioException e) {
    final status = e.response?.statusCode;
    final raw = e.response?.data;
    final bodyStr = raw == null ? '' : raw.toString();
    final shortBody = bodyStr.length > 400
        ? '${bodyStr.substring(0, 400)}…(truncated)'
        : bodyStr;

    AppLogger.log(
      'HTTP',
      '$context failed: type=${e.type} status=${status ?? '-'} '
          'msg=${e.message ?? '-'}\n  body: $shortBody',
      error: e,
    );

    final summary = StringBuffer();
    if (status != null) summary.write('HTTP $status');
    if (e.type != DioExceptionType.unknown) {
      if (summary.isNotEmpty) summary.write(' ');
      summary.write('(${e.type.name})');
    }
    if (e.message != null && e.message!.isNotEmpty) {
      if (summary.isNotEmpty) summary.write(' — ');
      summary.write(e.message);
    }
    if (shortBody.isNotEmpty) {
      summary.write('\n回應：$shortBody');
    }
    return Exception(summary.isEmpty ? e.toString() : summary.toString());
  }

  Future<TranscriptionResult> _transcribeWithOpenAI({
    required String audioFilePath,
    required String apiKey,
    required String model,
    required String prompt,
    String? customEndpoint,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        audioFilePath,
        filename: File(audioFilePath).uri.pathSegments.last,
      ),
      'model': model,
      'response_format': 'json',
      if (prompt.isNotEmpty) 'prompt': prompt,
    });

    final url = (customEndpoint != null && customEndpoint.isNotEmpty)
        ? customEndpoint
        : 'https://api.openai.com/v1/audio/transcriptions';

    AppLogger.log('OpenAI', 'POST $url model=$model');

    Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        url,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
      );
    } on DioException catch (e) {
      throw _wrapDioError('OpenAI/LiteLLM POST $url', e);
    }

    // Parse JSON response to extract text and token usage
    Map<String, dynamic>? data;
    if (response.data is Map<String, dynamic>) {
      data = response.data as Map<String, dynamic>;
    } else if (response.data is String) {
      try {
        data = jsonDecode(response.data as String) as Map<String, dynamic>;
      } catch (_) {
        return (
          text: (response.data as String).trim(),
          inputTokens: null,
          outputTokens: null,
        );
      }
    }

    final text = (data?['text'] as String? ?? '').trim();
    final usageMap = data?['usage'] as Map<String, dynamic>?;
    final inputTokens = usageMap?['input_tokens'] as int?;
    final outputTokens = usageMap?['output_tokens'] as int?;

    return (text: text, inputTokens: inputTokens, outputTokens: outputTokens);
  }

  Future<TranscriptionResult> _transcribeWithGemini({
    required String audioFilePath,
    required String apiKey,
    required String model,
    required String prompt,
    String? customEndpoint,
  }) async {
    AppLogger.log('Gemini', 'start: $audioFilePath');

    final fileToUpload = File(audioFilePath);
    if (!fileToUpload.existsSync()) {
      throw Exception('找不到音檔：$audioFilePath');
    }

    final mimeType = audioFilePath.endsWith('.m4a')
        ? 'audio/mp4'
        : (audioFilePath.endsWith('.mp3') ? 'audio/mpeg' : 'audio/mp4');
    final audioBytes = await fileToUpload.readAsBytes();
    final base64Audio = base64Encode(audioBytes);

    final finalPrompt =
        prompt.isEmpty ? 'Generate a transcript of the speech.' : prompt;

    final url = (customEndpoint != null && customEndpoint.isNotEmpty)
        ? '$customEndpoint/$model:generateContent'
        : 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: {
          'contents': [
            {
              'parts': [
                {'text': finalPrompt},
                {
                  'inline_data': {
                    'mime_type': mimeType,
                    'data': base64Audio,
                  }
                },
              ],
            },
          ],
        },
        options: Options(
          headers: {
            'x-goog-api-key': apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      final candidates = response.data?['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Gemini 轉譯失敗：無候選回應');
      }

      final parts = candidates[0]['content']?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('Gemini 轉譯失敗：內容為空');
      }

      final text = (parts[0]['text'] as String? ?? '').trim();

      // Extract token usage from usageMetadata
      final usageMeta =
          response.data?['usageMetadata'] as Map<String, dynamic>?;
      final inputTokens = usageMeta?['promptTokenCount'] as int?;
      final outputTokens = usageMeta?['candidatesTokenCount'] as int?;

      AppLogger.log('Gemini',
          'success tokens: in=$inputTokens out=$outputTokens');
      return (text: text, inputTokens: inputTokens, outputTokens: outputTokens);
    } on DioException catch (e) {
      throw _wrapDioError('Gemini POST $url', e);
    }
  }
}
