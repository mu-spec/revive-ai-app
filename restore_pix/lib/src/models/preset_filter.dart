import 'package:flutter/material.dart';

enum AiToolType {
  autoEnhance,
  oldPhotoRestore,
  faceEnhance,
  colorizeBw,
  denoiseUnblur,
  upscaleHd,
  cartoonAnime,
  backgroundCleanup,
}

class PresetFilter {
  final String id;
  final String label;
  final String subtitle;
  final AiToolType toolType;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isViral;
  final bool isPremium;

  PresetFilter({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.toolType,
    required this.icon,
    required this.gradientColors,
    this.isViral = false,
    this.isPremium = false,
  });
}

class PresetRepository {
  static List<PresetFilter> get allTools => [
        PresetFilter(
          id: 'auto_enhance',
          label: 'One-Tap Auto Enhance',
          subtitle: 'Instant clarity, sharpness & vivid colors',
          toolType: AiToolType.autoEnhance,
          icon: Icons.auto_awesome,
          gradientColors: [Colors.purpleAccent, Colors.deepPurple],
          isViral: true,
        ),
        PresetFilter(
          id: 'old_restore',
          label: 'Old Photo Restore',
          subtitle: 'Remove scratches, fade & fix damaged photos',
          toolType: AiToolType.oldPhotoRestore,
          icon: Icons.history_edu,
          gradientColors: [Colors.orangeAccent, Colors.deepOrange],
          isViral: true,
        ),
        PresetFilter(
          id: 'face_enhance',
          label: 'Face Enhance',
          subtitle: 'Improve eyes, skin & fix blurry faces',
          toolType: AiToolType.faceEnhance,
          icon: Icons.face_retouching_natural,
          gradientColors: [Colors.pinkAccent, Colors.redAccent],
        ),
        PresetFilter(
          id: 'colorize_bw',
          label: 'Colorize Black & White',
          subtitle: 'Bring vintage monochrome photos to life',
          toolType: AiToolType.colorizeBw,
          icon: Icons.palette_outlined,
          gradientColors: [Colors.greenAccent, Colors.teal],
          isViral: true,
        ),
        PresetFilter(
          id: 'denoise_unblur',
          label: 'Denoise / Unblur',
          subtitle: 'Remove grain, motion blur & camera shake',
          toolType: AiToolType.denoiseUnblur,
          icon: Icons.lens_blur_rounded,
          gradientColors: [Colors.blueAccent, Colors.indigo],
        ),
        PresetFilter(
          id: 'upscale_hd',
          label: 'HD / 4K Upscaler',
          subtitle: 'Sharpen details and double resolution',
          toolType: AiToolType.upscaleHd,
          icon: Icons.hd_outlined,
          gradientColors: [Colors.cyanAccent, Colors.blue],
          isPremium: true,
        ),
        PresetFilter(
          id: 'cartoon_anime',
          label: 'Cartoon / Anime',
          subtitle: 'Convert any portrait to viral anime art',
          toolType: AiToolType.cartoonAnime,
          icon: Icons.color_lens_outlined,
          gradientColors: [Colors.amberAccent, Colors.orange],
          isViral: true,
        ),
        PresetFilter(
          id: 'bg_cleanup',
          label: 'Background Focus',
          subtitle: 'Clean background and boost portrait pop',
          toolType: AiToolType.backgroundCleanup,
          icon: Icons.wallpaper_rounded,
          gradientColors: [Colors.deepPurpleAccent, Colors.indigo],
        ),
      ];
}
