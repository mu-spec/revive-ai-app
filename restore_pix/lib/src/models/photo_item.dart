import 'dart:typed_data';

class PhotoItem {
  final String id;
  final String? originalPath;
  final Uint8List? originalBytes;
  final String? enhancedPath;
  final Uint8List? enhancedBytes;
  final DateTime timestamp;
  final String appliedToolName;
  final Map<String, dynamic> settings;

  PhotoItem({
    required this.id,
    this.originalPath,
    this.originalBytes,
    this.enhancedPath,
    this.enhancedBytes,
    required this.timestamp,
    required this.appliedToolName,
    this.settings = const {},
  });

  PhotoItem copyWith({
    String? id,
    String? originalPath,
    Uint8List? originalBytes,
    String? enhancedPath,
    Uint8List? enhancedBytes,
    DateTime? timestamp,
    String? appliedToolName,
    Map<String, dynamic>? settings,
  }) {
    return PhotoItem(
      id: id ?? this.id,
      originalPath: originalPath ?? this.originalPath,
      originalBytes: originalBytes ?? this.originalBytes,
      enhancedPath: enhancedPath ?? this.enhancedPath,
      enhancedBytes: enhancedBytes ?? this.enhancedBytes,
      timestamp: timestamp ?? this.timestamp,
      appliedToolName: appliedToolName ?? this.appliedToolName,
      settings: settings ?? this.settings,
    );
  }
}
