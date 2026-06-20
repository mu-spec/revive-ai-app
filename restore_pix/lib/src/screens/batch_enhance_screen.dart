import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/photo_item.dart';
import '../models/preset_filter.dart';
import '../providers/app_state_provider.dart';
import '../services/local_ai_processor.dart';
import 'premium_paywall_screen.dart';

class BatchEnhanceScreen extends StatefulWidget {
  const BatchEnhanceScreen({Key? key}) : super(key: key);

  @override
  State<BatchEnhanceScreen> createState() => _BatchEnhanceScreenState();
}

class _BatchEnhanceScreenState extends State<BatchEnhanceScreen> {
  final ImagePicker _picker = ImagePicker();
  List<PhotoItem> _batchItems = [];
  bool _isBatchProcessing = false;
  double _batchProgress = 0.0;
  AiToolType _batchTool = AiToolType.autoEnhance;

  Future<void> _pickMultiPhotos() async {
    final sub = context.read<AppStateProvider>().subscription;
    if (!sub.isPremium) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()));
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 90);
      if (images.isEmpty) return;

      final List<PhotoItem> items = [];
      for (var img in images) {
        final bytes = await img.readAsBytes();
        items.add(PhotoItem(
          id: UniqueKey().toString(),
          originalPath: img.path,
          originalBytes: bytes,
          timestamp: DateTime.now(),
          appliedToolName: 'Pending Batch',
        ));
      }

      setState(() {
        _batchItems.addAll(items);
      });
    } catch (e) {
      debugPrint('Batch picker error: $e');
    }
  }

  Future<void> _runBatchProcessing() async {
    if (_batchItems.isEmpty) return;

    setState(() {
      _isBatchProcessing = true;
      _batchProgress = 0.0;
    });

    final int total = _batchItems.length;
    for (int i = 0; i < total; i++) {
      final item = _batchItems[i];
      if (item.originalBytes != null) {
        try {
          final enhBytes = await LocalAiProcessor.processImage(
            inputBytes: item.originalBytes!,
            toolType: _batchTool,
            intensity: 1.2,
          );

          // Save directly to gallery
          await ImageGallerySaver.saveImage(
            enhBytes,
            quality: 100,
            name: "reviveai_batch_${DateTime.now().millisecondsSinceEpoch}_$i",
          );

          setState(() {
            _batchItems[i] = item.copyWith(
              enhancedBytes: enhBytes,
              appliedToolName: 'Batch Restored HD',
            );
            _batchProgress = (i + 1) / total;
          });
        } catch (e) {
          debugPrint('Error processing batch item $i: $e');
        }
      }
    }

    setState(() {
      _isBatchProcessing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚡ Successfully restored & exported all $total memories to your Gallery!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<AppStateProvider>().subscription;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
        title: const Text('Batch Processor Studio'),
        actions: [
          if (_batchItems.isNotEmpty && !_isBatchProcessing)
            IconButton(
              icon: const Icon(Icons.clear_all_rounded, color: Colors.white54),
              onPressed: () {
                setState(() {
                  _batchItems.clear();
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Setup / Tools bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF161824),
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.batch_prediction_rounded, color: Color(0xFFFFD700), size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mode: Unlimited Batch AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 2),
                        Text('Pro Feature: Ultra-fast automatic processing', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (!sub.isPremium)
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('PRO', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),

            // Mode Picker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Enhancement Mode:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                  DropdownButton<AiToolType>(
                    value: _batchTool,
                    dropdownColor: const Color(0xFF1F2232),
                    style: const TextStyle(color: Color(0xFF00F0FF), fontWeight: FontWeight.bold),
                    underline: const SizedBox(),
                    items: PresetRepository.allTools.map((t) {
                      return DropdownMenuItem(
                        value: t.toolType,
                        child: Text(t.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _batchTool = val);
                    },
                  ),
                ],
              ),
            ),

            // Items Grid
            Expanded(
              child: _batchItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F2232),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Icon(Icons.add_photo_alternate_rounded, size: 64, color: Color(0xFF7A11FF)),
                          ),
                          const SizedBox(height: 20),
                          const Text('Select multiple photos to restore in 1-click', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Works instantly and saves directly to Android Gallery', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _pickMultiPhotos,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF1178),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 24),
                            label: const Text('Pick Gallery Photos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        GridView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _batchItems.length,
                          itemBuilder: (context, index) {
                            final item = _batchItems[index];
                            final isDone = item.enhancedBytes != null;

                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2232),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDone ? const Color(0xFF00F0FF) : Colors.white12, width: isDone ? 2 : 1),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (isDone)
                                      Image.memory(item.enhancedBytes!, fit: BoxFit.cover)
                                    else if (item.originalBytes != null)
                                      Image.memory(item.originalBytes!, fit: BoxFit.cover)
                                    else
                                      const Icon(Icons.image, color: Colors.white24),

                                    // Overlay status
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: isDone
                                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00F0FF), size: 16)
                                            : const Icon(Icons.access_time_filled_rounded, color: Colors.orangeAccent, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        if (_isBatchProcessing)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.85),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SpinKitCubeGrid(color: Color(0xFF00F0FF), size: 50.0),
                                    const SizedBox(height: 24),
                                    Text('Restoring Batch Memories (${(_batchProgress * 100).toInt()}%)...', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 48.0),
                                      child: LinearProgressIndicator(
                                        value: _batchProgress,
                                        backgroundColor: Colors.white12,
                                        color: const Color(0xFFFF1178),
                                        minHeight: 8,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),

            // Start Batch Action Bar
            if (_batchItems.isNotEmpty && !_isBatchProcessing)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF161824),
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${_batchItems.length} photos ready for batch processing', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                    ElevatedButton.icon(
                      onPressed: _runBatchProcessing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A11FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 24),
                      label: const Text('Start AI Batch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
