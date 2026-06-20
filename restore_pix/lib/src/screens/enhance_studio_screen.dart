import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/preset_filter.dart';
import '../providers/app_state_provider.dart';
import '../widgets/before_after_slider.dart';
import 'premium_paywall_screen.dart';

class EnhanceStudioScreen extends StatefulWidget {
  final AiToolType initialTool;

  const EnhanceStudioScreen({
    Key? key,
    required this.initialTool,
  }) : super(key: key);

  @override
  State<EnhanceStudioScreen> createState() => _EnhanceStudioScreenState();
}

class _EnhanceStudioScreenState extends State<EnhanceStudioScreen> {
  double _intensity = 1.0;
  bool _hasProcessedOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runEnhancement(widget.initialTool);
    });
  }

  Future<void> _runEnhancement(AiToolType toolType) async {
    final provider = context.read<AppStateProvider>();
    provider.setActiveTool(toolType);
    final tool = PresetRepository.allTools.firstWhere((t) => t.toolType == toolType);

    final success = await provider.executeEnhancement(tool, intensity: _intensity);
    if (success && mounted) {
      setState(() {
        _hasProcessedOnce = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final activePhoto = provider.activePhoto;
    final isProcessing = provider.isProcessing;
    final subscription = provider.subscription;
    final tools = PresetRepository.allTools;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
        title: Text(provider.activeTool.name.toUpperCase()),
        actions: [
          // Save / Export shiny Pro/Free Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: (isProcessing || activePhoto?.enhancedBytes == null)
                  ? null
                  : () => _showExportModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF1178),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: const Color(0xFFFF1178).withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.file_download_rounded, size: 20),
              label: const Text('Export HD', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Center Studio View: Shows interactive split slider or AI scanning animation
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161824),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main image workspace
                    if (activePhoto?.originalBytes != null && activePhoto?.enhancedBytes != null && _hasProcessedOnce)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BeforeAfterSlider(
                            beforeImageBytes: activePhoto!.originalBytes!,
                            afterImageBytes: activePhoto.enhancedBytes!,
                            beforeLabel: 'Original',
                            afterLabel: 'Enhanced AI',
                          ),
                        ),
                      )
                    else if (activePhoto?.originalBytes != null)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.memory(
                            activePhoto!.originalBytes!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    else
                      const Center(child: Text('No photo loaded.', style: TextStyle(color: Colors.white54))),

                    // Gorgeous Active AI Scanning/Processing Overlay
                    if (isProcessing)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Glowing AI Sparkles
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF7A11FF).withOpacity(0.6),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFFFF1178).withOpacity(0.6),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SpinKitCubeGrid(
                                      color: Color(0xFF00F0FF),
                                      size: 50.0,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  'Revive AI Engine Active',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    provider.processingStep,
                                    style: const TextStyle(
                                      color: Color(0xFF00F0FF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
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
            ),

            // AI Restoration Chips Hub
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF161824),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Choose AI Tool',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Tap to Apply instantly',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: tools.map((tool) {
                        final isSelected = provider.activeTool == tool.toolType;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              if (tool.isPremium && !subscription.isPremium) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()));
                                return;
                              }
                              _runEnhancement(tool.toolType);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(colors: tool.gradientColors)
                                    : null,
                                color: isSelected ? null : const Color(0xFF1F2232),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.08),
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: tool.gradientColors[0].withOpacity(0.4), blurRadius: 10)]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  Icon(tool.icon, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    tool.label,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (tool.isPremium && !subscription.isPremium) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.lock_outline_rounded, color: Color(0xFFFFD700), size: 14),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Intensity Adjustment Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        const Icon(Icons.tune_rounded, color: Colors.white54, size: 18),
                        const SizedBox(width: 12),
                        const Text('Enhance Intensity:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Expanded(
                          child: Slider(
                            value: _intensity,
                            min: 0.5,
                            max: 1.5,
                            divisions: 4,
                            activeColor: const Color(0xFF00F0FF),
                            inactiveColor: Colors.white24,
                            onChanged: (val) {
                              setState(() {
                                _intensity = val;
                              });
                            },
                            onChangeEnd: (_) => _runEnhancement(provider.activeTool),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Immersive Export Modal with Viral Social Sharing and Direct Gallery Download
  void _showExportModal(BuildContext context) {
    final provider = context.read<AppStateProvider>();
    final sub = provider.subscription;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161824),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal Title
              const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00F0FF), size: 48),
              const SizedBox(height: 12),
              const Text(
                'AI Restoration Ready!',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Your old memory has been perfectly restored.',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Pro/Free Status Banner
              if (!sub.isPremium)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.15),
                    border: Border.all(color: const Color(0xFFFFD700)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Unlock Revive Pro',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Remove ReviveAI Watermark & get unlimited 4K resolution exports instantly.',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('PRO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Core Export Actions
              ElevatedButton.icon(
                onPressed: () async {
                  // Actually save to gallery
                  try {
                    final savedPath = await provider.saveActiveMemoryToGallery();
                    if (savedPath != null) {
                      // Save to actual Android gallery using ImageGallerySaver
                      final enhBytes = provider.activePhoto!.enhancedBytes!;
                      await ImageGallerySaver.saveImage(
                        enhBytes,
                        quality: 100,
                        name: "reviveai_${DateTime.now().millisecondsSinceEpoch}",
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📸 Successfully saved high-quality image to your Android Gallery!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (e.toString().contains('FREE_LIMIT_REACHED')) {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving photo: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A11FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.download_rounded, size: 24),
                label: const Text('Save to Android Gallery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),

              // Viral Marketing Sharing Links
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Viral Social Sharing (Before / After)', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildViralShareButton(
                        icon: Icons.tiktok_rounded,
                        label: 'TikTok',
                        color: Colors.cyanAccent,
                        onTap: () => _shareEnhancedPhoto(context, 'TikTok'),
                      ),
                      _buildViralShareButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'Insta Reels',
                        color: Colors.pinkAccent,
                        onTap: () => _shareEnhancedPhoto(context, 'Instagram'),
                      ),
                      _buildViralShareButton(
                        icon: Icons.play_arrow_rounded,
                        label: 'Shorts',
                        color: Colors.redAccent,
                        onTap: () => _shareEnhancedPhoto(context, 'YouTube Shorts'),
                      ),
                      _buildViralShareButton(
                        icon: Icons.share_rounded,
                        label: 'More',
                        color: Colors.greenAccent,
                        onTap: () => _shareEnhancedPhoto(context, 'Social Media'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViralShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2232),
              border: Border.all(color: color.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.2), blurRadius: 10),
              ],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _shareEnhancedPhoto(BuildContext context, String platform) async {
    final provider = context.read<AppStateProvider>();
    if (provider.activePhoto?.enhancedPath == null && provider.activePhoto?.enhancedBytes != null) {
      // Save it temporarily so we can share it via Share.shareXFiles
      await provider.saveActiveMemoryToGallery();
    }

    final enhPath = provider.activePhoto?.enhancedPath;
    if (enhPath != null) {
      final file = XFile(enhPath);
      await Share.shareXFiles(
        [file],
        text: 'Just restored my old family memories to 4K HD with #ReviveAI! Download now to fix your blurry photos. ✨ @ReviveAI',
      );
    }
  }
}
