import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/photo_item.dart';
import '../providers/app_state_provider.dart';
import '../widgets/before_after_slider.dart';
import 'home_screen.dart';

class MyMemoriesScreen extends StatelessWidget {
  const MyMemoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final memories = provider.memories;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
        title: const Text('My Restored Memories'),
        actions: [
          if (memories.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${memories.length} Items',
                  style: const TextStyle(color: Color(0xFF00F0FF), fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: memories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded, size: 80, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text('No restored memories yet.', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('When you restore and save photos, they appear here.', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF1178),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Restore A Photo Now'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: memories.length,
              itemBuilder: (context, index) {
                final memory = memories[index];
                return _buildMemoryCard(context, memory);
              },
            ),
    );
  }

  Widget _buildMemoryCard(BuildContext context, PhotoItem memory) {
    final enhBytes = memory.enhancedBytes;
    final dateStr = '${memory.timestamp.year}-${memory.timestamp.month.toString().padLeft(2, '0')}-${memory.timestamp.day.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => _showMemoryDetailModal(context, memory),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2232),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Enhanced Image Preview
              if (enhBytes != null)
                Positioned.fill(
                  child: Image.memory(enhBytes, fit: BoxFit.cover),
                )
              else
                const Center(child: Icon(Icons.broken_image, color: Colors.white24)),

              // Tool Badge Overlay
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    memory.appliedToolName,
                    style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Bottom Date and Actions Banner
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateStr, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (memory.enhancedPath != null) {
                                Share.shareXFiles([XFile(memory.enhancedPath!)], text: '#ReviveAI Memory Restored');
                              }
                            },
                            child: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => context.read<AppStateProvider>().deleteMemory(memory.id),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMemoryDetailModal(BuildContext context, PhotoItem memory) {
    if (memory.originalBytes == null || memory.enhancedBytes == null) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF161824),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Memory Inspection', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Restored with ${memory.appliedToolName}', style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 12)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BeforeAfterSlider(
                    beforeImageBytes: memory.originalBytes!,
                    afterImageBytes: memory.enhancedBytes!,
                    beforeLabel: 'Damaged Original',
                    afterLabel: 'Restored Result',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (memory.enhancedPath != null) {
                    Share.shareXFiles([XFile(memory.enhancedPath!)], text: 'Look at how beautifully I restored this old memory with ReviveAI! ✨');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1178),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.ios_share_rounded, size: 20),
                label: const Text('Share Viral Comparison', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
