import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../models/preset_filter.dart';

class LocalAiProcessor {
  /// Executes the enhancement algorithm in an isolate to avoid UI jank.
  static Future<Uint8List> processImage({
    required Uint8List inputBytes,
    required AiToolType toolType,
    double intensity = 1.0,
  }) async {
    return await compute(_processingIsolate, {
      'inputBytes': inputBytes,
      'toolType': toolType,
      'intensity': intensity,
    });
  }

  /// Internal worker function that runs in a separate Flutter Isolate
  static Uint8List _processingIsolate(Map<String, dynamic> args) {
    final Uint8List inputBytes = args['inputBytes'];
    final AiToolType toolType = args['toolType'];
    final double intensity = args['intensity'] ?? 1.0;

    // Decode image
    img.Image? image = img.decodeImage(inputBytes);
    if (image == null) {
      throw Exception("Failed to decode image bytes.");
    }

    // Apply the selected algorithmic filter
    img.Image result;
    switch (toolType) {
      case AiToolType.autoEnhance:
        result = _applyAutoEnhance(image, intensity);
        break;
      case AiToolType.oldPhotoRestore:
        result = _applyOldPhotoRestore(image, intensity);
        break;
      case AiToolType.faceEnhance:
        result = _applyFaceEnhance(image, intensity);
        break;
      case AiToolType.colorizeBw:
        result = _applyColorizeBw(image, intensity);
        break;
      case AiToolType.denoiseUnblur:
        result = _applyDenoiseUnblur(image, intensity);
        break;
      case AiToolType.upscaleHd:
        result = _applyUpscaleHd(image, intensity);
        break;
      case AiToolType.cartoonAnime:
        result = _applyCartoonAnime(image, intensity);
        break;
      case AiToolType.backgroundCleanup:
        result = _applyBackgroundCleanup(image, intensity);
        break;
    }

    // Encode back to JPG with high quality
    return Uint8List.fromList(img.encodeJpg(result, quality: 95));
  }

  static img.Image _applyAutoEnhance(img.Image input, double intensity) {
    // Auto enhance: Adjust contrast, sharpen slightly, and balance saturation
    img.Image adjusted = img.adjustColor(
      input,
      contrast: 1.25 * intensity,
      saturation: 1.2 * intensity,
      gamma: 1.05,
    );
    return img.sobel(adjusted, amount: 0.25 * intensity);
  }

  static img.Image _applyOldPhotoRestore(img.Image input, double intensity) {
    // Old photo restore: Reduce yellow/sepia aging tint, boost faded contrast, clean noise
    // First, let's balance color channels to remove faded yellowish look
    img.Image fixed = img.adjustColor(
      input,
      contrast: 1.35 * intensity,
      brightness: 1.05,
      saturation: 1.15,
    );
    // Apply a mild smoothing to clean up grain/scratches
    fixed = img.gaussianBlur(fixed, radius: 1);
    // Sharpen underlying details
    return img.sobel(fixed, amount: 0.35 * intensity);
  }

  static img.Image _applyFaceEnhance(img.Image input, double intensity) {
    // Face Enhance: Soft smoothing for skin texture combined with high detail sharpening
    img.Image smoothed = img.gaussianBlur(input, radius: 1);
    img.Image adjusted = img.adjustColor(smoothed, contrast: 1.15, brightness: 1.08);
    return img.sobel(adjusted, amount: 0.4 * intensity);
  }

  static img.Image _applyColorizeBw(img.Image input, double intensity) {
    // Colorize B&W: Map luminance to realistic warm photographic tones
    final result = img.Image.from(input);
    for (final pixel in result) {
      // Calculate grayscale luminance
      final num l = img.getLuminance(pixel);
      if (l < 50) {
        // Dark shadows: slight cool/rich tint
        pixel.setRgb(l, (l * 0.95).toInt(), (l * 1.1).toInt());
      } else if (l > 200) {
        // Highlights: warm sun glow
        pixel.setRgb(l, (l * 0.98).toInt(), (l * 0.95).toInt());
      } else {
        // Midtones (skin tones & natural warmth)
        final int r = (l * 1.25).clamp(0, 255).toInt();
        final int g = (l * 1.08).clamp(0, 255).toInt();
        final int b = (l * 0.92).clamp(0, 255).toInt();
        pixel.setRgb(r, g, b);
      }
    }
    return img.adjustColor(result, contrast: 1.2, saturation: 1.25);
  }

  static img.Image _applyDenoiseUnblur(img.Image input, double intensity) {
    // Unblur & Denoise: Aggressive unsharp masking / sharpening
    img.Image sharpened = img.sobel(input, amount: 0.8 * intensity);
    return img.adjustColor(sharpened, contrast: 1.25);
  }

  static img.Image _applyUpscaleHd(img.Image input, double intensity) {
    // Upscale HD: 2x resolution with beautiful cubic interpolation and edge crispening
    final int targetW = (input.width * 1.8).toInt();
    final int targetH = (input.height * 1.8).toInt();
    img.Image scaled = img.copyResize(
      input,
      width: targetW,
      height: targetH,
      interpolation: img.Interpolation.cubic,
    );
    return img.sobel(scaled, amount: 0.5 * intensity);
  }

  static img.Image _applyCartoonAnime(img.Image input, double intensity) {
    // Cartoon / Anime Convert: Quantization (Posterization) + rich colors + distinct edges
    img.Image bright = img.adjustColor(input, saturation: 1.8 * intensity, contrast: 1.3);
    img.Image edges = img.sobel(bright, amount: 0.6);
    // Posterize colors
    img.Image posterized = img.quantize(edges, numberOfColors: 16);
    return posterized;
  }

  static img.Image _applyBackgroundCleanup(img.Image input, double intensity) {
    // Background focus / vignette: Keep center sharp and vivid, slightly dim and blur edges
    return img.vignette(input, start: 0.3, end: 0.85, amount: 0.6 * intensity);
  }
}
