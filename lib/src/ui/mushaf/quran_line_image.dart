import 'package:flutter/material.dart';
import '../../data/quran/quran_data_provider.dart';

/// Displays a single Quran line image loaded from assets.
///
/// Images are stored in assets/quran-images/{page}/{line}.png
/// Original dimensions: 1440 x 232 pixels
/// Each page has 15 lines (1-15).
///
/// Port of the Android QuranLineImageView composable.
class QuranLineImage extends StatefulWidget {
  final int page;
  final int line;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const QuranLineImage({
    super.key,
    required this.page,
    required this.line,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  State<QuranLineImage> createState() => _QuranLineImageState();
}

class _QuranLineImageState extends State<QuranLineImage> {
  // Original image aspect ratio: 1440 x 232
  static const double _aspectRatio = 1440.0 / 232.0;

  @override
  Widget build(BuildContext context) {
    final assetPath = QuranDataProvider.getLineImagePath(
      widget.page,
      widget.line,
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Highlight background
            if (widget.isHighlighted)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A574).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

            // Line image — loaded from package assets
            Image.asset(
              assetPath,
              package: 'imad_flutter',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Silently show empty space for missing images
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
