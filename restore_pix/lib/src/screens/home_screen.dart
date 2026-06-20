import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/preset_filter.dart';
import '../providers/app_state_provider.dart';
import '../widgets/premium_app_bar.dart';
import 'enhance_studio_screen.dart';
import 'batch_enhance_screen.dart';
import 'my_memories_screen.dart';
import 'premium_paywall_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Helper to pick image from camera or gallery and launch Studio
  Future<void> _pickImageAndEnhance(ImageSource source, AiToolType toolType) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (!mounted) return;

      context.read<AppStateProvider>().setActiveTool(toolType);
      await context.read<AppStateProvider>().setActivePhoto(bytes, filePath: file.path);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EnhanceStudioScreen(initialTool: toolType),
        ),
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open photo: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// Load builtin sample image from assets and launch Studio
  Future<void> _loadSampleAndEnhance(String assetPath, AiToolType toolType) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      if (!mounted) return;
      context.read<AppStateProvider>().setActiveTool(toolType);
      await context.read<AppStateProvider>().setActivePhoto(bytes);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EnhanceStudioScreen(initialTool: toolType),
        ),
      );
    } catch (e) {
      debugPrint('Error loading sample asset: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sample image missing or could not load: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<AppStateProvider>().subscription;

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Restore Old Memories',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spectacular Hero Emotional Banner
            _buildHeroBanner(context),
            const SizedBox(height: 24),

            // Demo Instant Samples Box
            _buildSampleTryBox(context),
            const SizedBox(height: 28),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Features Studio',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (!subscription.isPremium)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Unlock All',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: Color(0xFFFFD700), size: 18),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Core Features Grid
            _buildFeaturesGrid(context),
            const SizedBox(height: 32),

            // Batch Processing & History Bottom Cards
            _buildBottomUtilityCards(context),
            const SizedBox(height: 48),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActionSheet(context),
        backgroundColor: const Color(0xFFFF1178),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text(
          'Enhance Photo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Gorgeous Hero Banner with Before/After Marketing positioning
  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7A11FF), Color(0xFFFF1178), Color(0xFF00F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A11FF).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                SizedBox(width: 6),
                Text(
                  '#1 Trending Play Store Idea',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bring Old Photos\nBack to Life',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Fix blurry faces, restore faded colors, and upscale to ultra-crisp HD instantly.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImageAndEnhance(ImageSource.gallery, AiToolType.autoEnhance),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF7A11FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 20),
                label: const Text('Open Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _pickImageAndEnhance(ImageSource.camera, AiToolType.autoEnhance),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.2),
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Instant Sample Try Out Box
  Widget _buildSampleTryBox(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Try With Sample Photos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildSampleCard(
                context: context,
                label: 'Old Photo (1956)',
                assetPath: 'assets/samples/old_photo.jpg',
                toolType: AiToolType.oldPhotoRestore,
                icon: Icons.history_edu,
                gradient: const [Colors.orangeAccent, Colors.deepOrange],
              ),
              const SizedBox(width: 12),
              _buildSampleCard(
                context: context,
                label: 'Blurry Face',
                assetPath: 'assets/samples/blurry_face.jpg',
                toolType: AiToolType.faceEnhance,
                icon: Icons.face_retouching_natural,
                gradient: const [Colors.pinkAccent, Colors.redAccent],
              ),
              const SizedBox(width: 12),
              _buildSampleCard(
                context: context,
                label: 'Black & White',
                assetPath: 'assets/samples/bw_photo.jpg',
                toolType: AiToolType.colorizeBw,
                icon: Icons.palette_outlined,
                gradient: const [Colors.greenAccent, Colors.teal],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSampleCard({
    required BuildContext context,
    required String label,
    required String assetPath,
    required AiToolType toolType,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return GestureDetector(
      onTap: () => _loadSampleAndEnhance(assetPath, toolType),
      child: Container(
        width: 140,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2232),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A11FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'TRY NOW',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
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

  /// Full Core Features Grid
  Widget _buildFeaturesGrid(BuildContext context) {
    final tools = PresetRepository.allTools;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return _buildToolGridItem(context, tool);
      },
    );
  }

  Widget _buildToolGridItem(BuildContext context, PresetFilter tool) {
    return GestureDetector(
      onTap: () => _pickImageAndEnhance(ImageSource.gallery, tool.toolType),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2232),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gorgeous Graded Icon Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: tool.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: tool.gradientColors[0].withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(tool.icon, color: Colors.white, size: 24),
                ),
                if (tool.isViral)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF1178).withOpacity(0.2),
                      border: Border.all(color: const Color(0xFFFF1178)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF1178), size: 12),
                        SizedBox(width: 4),
                        Text(
                          'VIRAL',
                          style: TextStyle(color: Color(0xFFFF1178), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                if (tool.isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      border: Border.all(color: const Color(0xFFFFD700)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 12),
                        SizedBox(width: 4),
                        Text(
                          'PRO',
                          style: TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tool.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFA0A3B5),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Utility Links (Batch Processing & History Repository)
  Widget _buildBottomUtilityCards(BuildContext context) {
    return Column(
      children: [
        // Batch Enhance Box
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BatchEnhanceScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF161824), Color(0xFF1F2232)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFFFFD700), size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Batch Enhance Studio',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 16),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Enhance 10+ photos at once automatically',
                        style: TextStyle(color: Color(0xFFA0A3B5), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // My Memories Gallery Box
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyMemoriesScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2232),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F0FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.history_rounded, color: Color(0xFF00F0FF), size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Restored Memories',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'View history, compare Before/After & share',
                        style: TextStyle(color: Color(0xFFA0A3B5), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Navigation Drawer for easy access
  Widget _buildNavigationDrawer(BuildContext context) {
    final sub = context.watch<AppStateProvider>().subscription;

    return Drawer(
      backgroundColor: const Color(0xFF161824),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7A11FF), Color(0xFFFF1178)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: const Text(
              'ReviveAI Premium Suite',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(sub.isPremium ? 'Pro Subscription Active' : 'Free Tier (${sub.freeExportsRemaining} Daily Exports)'),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF7A11FF), size: 36),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Color(0xFF00F0FF)),
            title: const Text('My Saved Memories'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyMemoriesScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium, color: Color(0xFFFFD700)),
            title: const Text('Upgrade to Revive Pro'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.batch_prediction, color: Color(0xFFFF1178)),
            title: const Text('Batch Processor Studio'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BatchEnhanceScreen()));
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text('Settings & API Key Manager'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded, color: Colors.greenAccent),
            title: const Text('Share ReviveAI App'),
            onTap: () {
              // Share app promo
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0 (Android Production)',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Modal Bottom Sheet when clicking Floating Action Button
  void _showQuickActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2232),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Photo Source',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionSheetOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: const Color(0xFF7A11FF),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageAndEnhance(ImageSource.gallery, AiToolType.autoEnhance);
                  },
                ),
                _buildActionSheetOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: const Color(0xFFFF1178),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageAndEnhance(ImageSource.camera, AiToolType.autoEnhance);
                  },
                ),
                _buildActionSheetOption(
                  icon: Icons.history_edu_rounded,
                  label: 'Sample Old',
                  color: const Color(0xFFFFD700),
                  onTap: () {
                    Navigator.pop(context);
                    _loadSampleAndEnhance('assets/samples/old_photo.jpg', AiToolType.oldPhotoRestore);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSheetOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
