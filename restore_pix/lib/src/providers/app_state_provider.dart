import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/photo_item.dart';
import '../models/preset_filter.dart';
import '../models/subscription_tier.dart';
import '../services/local_ai_processor.dart';
import '../services/cloud_ai_processor.dart';

class AppStateProvider extends ChangeNotifier {
  late SubscriptionTier _subscription;
  List<PhotoItem> _memories = [];
  PhotoItem? _activePhoto;
  bool _isProcessing = false;
  String _processingStep = '';
  AiToolType _activeTool = AiToolType.autoEnhance;
  bool _useCloudEngine = false;
  String _cloudApiKey = '';

  // Constants
  static const String _prefsProKey = 'reviveai_is_premium';
  static const String _prefsExportsKey = 'reviveai_exports_today';
  static const String _prefsDateKey = 'reviveai_last_export_date';
  static const String _prefsMemoriesKey = 'reviveai_saved_memories';
  static const String _prefsCloudKey = 'reviveai_use_cloud';
  static const String _prefsApiKey = 'reviveai_api_key';

  AppStateProvider() {
    // Default subscription
    _subscription = SubscriptionTier(
      isPremium: false,
      freeExportsRemaining: 3,
      showWatermark: true,
      showAds: true,
    );
    _loadState();
  }

  // Getters
  SubscriptionTier get subscription => _subscription;
  List<PhotoItem> get memories => _memories;
  PhotoItem? get activePhoto => _activePhoto;
  bool get isProcessing => _isProcessing;
  String get processingStep => _processingStep;
  AiToolType get activeTool => _activeTool;
  bool get useCloudEngine => _useCloudEngine;
  String get cloudApiKey => _cloudApiKey;

  // Initialize and load preferences
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Subscription Tier & daily export reset
    final isPro = prefs.getBool(_prefsProKey) ?? false;
    final lastExportDate = prefs.getString(_prefsDateKey) ?? '';
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    int freeRemaining = 3;
    if (lastExportDate == todayStr) {
      freeRemaining = prefs.getInt(_prefsExportsKey) ?? 3;
    } else {
      // Reset for a new day!
      await prefs.setString(_prefsDateKey, todayStr);
      await prefs.setInt(_prefsExportsKey, 3);
    }

    _subscription = SubscriptionTier(
      isPremium: isPro,
      freeExportsRemaining: isPro ? 999 : freeRemaining,
      showWatermark: !isPro,
      showAds: !isPro,
    );

    // Load AI Engine configs
    _useCloudEngine = prefs.getBool(_prefsCloudKey) ?? false;
    _cloudApiKey = prefs.getString(_prefsApiKey) ?? '';

    // Load Saved Memories History
    _memories = await _loadSavedMemoriesFromDisk();
    notifyListeners();
  }

  Future<List<PhotoItem>> _loadSavedMemoriesFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsMemoriesKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      final List<PhotoItem> items = [];

      for (var map in decoded) {
        try {
          final id = map['id'] ?? UniqueKey().toString();
          final timestamp = DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now();
          final appliedToolName = map['appliedToolName'] ?? 'Enhanced';
          final origPath = map['originalPath'];
          final enhPath = map['enhancedPath'];

          Uint8List? origBytes;
          Uint8List? enhBytes;

          if (origPath != null && File(origPath).existsSync()) {
            origBytes = await File(origPath).readAsBytes();
          }
          if (enhPath != null && File(enhPath).existsSync()) {
            enhBytes = await File(enhPath).readAsBytes();
          }

          if (origBytes != null && enhBytes != null) {
            items.add(PhotoItem(
              id: id,
              originalPath: origPath,
              originalBytes: origBytes,
              enhancedPath: enhPath,
              enhancedBytes: enhBytes,
              timestamp: timestamp,
              appliedToolName: appliedToolName,
            ));
          }
        } catch (e) {
          debugPrint('Error decoding single memory: $e');
        }
      }
      return items;
    } catch (e) {
      debugPrint('Error decoding memories history: $e');
      return [];
    }
  }

  Future<void> _saveMemoriesToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> mapped = _memories.map((m) => {
      'id': m.id,
      'timestamp': m.timestamp.toIso8601String(),
      'appliedToolName': m.appliedToolName,
      'originalPath': m.originalPath,
      'enhancedPath': m.enhancedPath,
    }).toList();

    await prefs.setString(_prefsMemoriesKey, jsonEncode(mapped));
  }

  // User Action Methods

  /// Set the active photo to be edited in the Enhance Studio
  Future<void> setActivePhoto(Uint8List imageBytes, {String? filePath}) async {
    _activePhoto = PhotoItem(
      id: UniqueKey().toString(),
      originalBytes: imageBytes,
      originalPath: filePath,
      timestamp: DateTime.now(),
      appliedToolName: PresetRepository.allTools.firstWhere((t) => t.toolType == _activeTool).label,
    );
    notifyListeners();
  }

  /// Change active AI Tool
  void setActiveTool(AiToolType tool) {
    _activeTool = tool;
    notifyListeners();
  }

  /// Execute the actual AI / Algorithmic Photo Restoration
  Future<bool> executeEnhancement(PresetFilter filter, {double intensity = 1.0}) async {
    if (_activePhoto == null || _activePhoto!.originalBytes == null) return false;

    _isProcessing = true;
    _processingStep = 'Analyzing resolution & face details...';
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      _processingStep = 'Applying AI restoration algorithms...';
      notifyListeners();

      Uint8List resultBytes;
      if (_useCloudEngine && _cloudApiKey.isNotEmpty) {
        _processingStep = 'Connecting to Cloud GPU AI...';
        notifyListeners();
        resultBytes = await CloudAiProcessor.callCloudApi(
          imageBytes: _activePhoto!.originalBytes!,
          endpointUrl: 'https://api.stability.ai/v2beta/stable-image/upscale/conservative', // sample
          apiKey: _cloudApiKey,
          parameters: {'prompt': filter.label},
        );
      } else {
        resultBytes = await LocalAiProcessor.processImage(
          inputBytes: _activePhoto!.originalBytes!,
          toolType: filter.toolType,
          intensity: intensity,
        );
      }

      await Future.delayed(const Duration(milliseconds: 400));
      _processingStep = 'Finalizing crisp details...';
      notifyListeners();

      // If the user is on the Free tier, let's optionally add a beautiful transparent watermark
      // Actually, we can add the watermark overlay directly in the export or Flutter canvas view so they can see it.

      _activePhoto = _activePhoto!.copyWith(
        enhancedBytes: resultBytes,
        appliedToolName: filter.label,
        timestamp: DateTime.now(),
      );

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Enhancement error: $e');
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Save Enhanced Memory to Device History Gallery & Local Directory
  Future<String?> saveActiveMemoryToGallery() async {
    if (_activePhoto == null || _activePhoto!.enhancedBytes == null || _activePhoto!.originalBytes == null) {
      return null;
    }

    // Check monetization free limits
    if (!_subscription.isPremium && _subscription.freeExportsRemaining <= 0) {
      throw Exception('FREE_LIMIT_REACHED');
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final folder = Directory('${appDir.path}/reviveai_memories');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final timestampStr = DateTime.now().millisecondsSinceEpoch;
      final origFile = File('${folder.path}/orig_$timestampStr.jpg');
      final enhFile = File('${folder.path}/enh_$timestampStr.jpg');

      await origFile.writeAsBytes(_activePhoto!.originalBytes!);
      await enhFile.writeAsBytes(_activePhoto!.enhancedBytes!);

      final finalItem = _activePhoto!.copyWith(
        id: UniqueKey().toString(),
        originalPath: origFile.path,
        enhancedPath: enhFile.path,
      );

      _memories.insert(0, finalItem);
      await _saveMemoriesToDisk();

      // Decrement export limit for free users
      if (!_subscription.isPremium) {
        final prefs = await SharedPreferences.getInstance();
        final newCount = _subscription.freeExportsRemaining - 1;
        await prefs.setInt(_prefsExportsKey, newCount);
        _subscription = _subscription.copyWith(freeExportsRemaining: newCount);
      }

      notifyListeners();
      return enhFile.path;
    } catch (e) {
      debugPrint('Error saving memory: $e');
      return null;
    }
  }

  /// Delete a saved memory
  Future<void> deleteMemory(String id) async {
    final memory = _memories.firstWhere((m) => m.id == id);
    if (memory.originalPath != null) {
      final f1 = File(memory.originalPath!);
      if (await f1.exists()) await f1.delete();
    }
    if (memory.enhancedPath != null) {
      final f2 = File(memory.enhancedPath!);
      if (await f2.exists()) await f2.delete();
    }

    _memories.removeWhere((m) => m.id == id);
    await _saveMemoriesToDisk();
    notifyListeners();
  }

  /// Toggle Premium Subscription (Instant unlock for developer/user)
  Future<void> unlockPremium(bool unlock) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsProKey, unlock);

    _subscription = _subscription.copyWith(
      isPremium: unlock,
      freeExportsRemaining: unlock ? 999 : (prefs.getInt(_prefsExportsKey) ?? 3),
      showWatermark: !unlock,
      showAds: !unlock,
    );
    notifyListeners();
  }

  /// Switch between On-Device AI Engine and Cloud API Key
  Future<void> toggleEngine(bool useCloud) async {
    _useCloudEngine = useCloud;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsCloudKey, useCloud);
    notifyListeners();
  }

  /// Save new API key
  Future<void> setCloudApiKey(String key) async {
    _cloudApiKey = key.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsApiKey, _cloudApiKey);
    notifyListeners();
  }

  /// Reset Daily Free Exports limit (Convenience feature for developer testing)
  Future<void> resetFreeExportsLimit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsExportsKey, 3);
    _subscription = _subscription.copyWith(freeExportsRemaining: 3);
    notifyListeners();
  }
}
