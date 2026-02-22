import 'package:flutter/material.dart';
import '../../data/quran/quran_data_provider.dart';

/// VerseFasel — renders a verse number marker (circle with Arabic numeral).
///
/// Port of the Android VerseFasel composable.
class VerseFasel extends StatelessWidget {
  final int number;
  final double size;

  const VerseFasel({super.key, required this.number, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF8B7355), width: 1.5),
        color: const Color(0xFFFDF5E6).withValues(alpha: 0.9),
      ),
      child: Center(
        child: Text(
          QuranDataProvider.toArabicNumerals(number),
          style: TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5C4033),
            height: 1.0,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
