import 'package:flutter/material.dart';
import '../../data/quran/quran_data_provider.dart';
import '../../data/quran/quran_metadata.dart';
import 'quran_line_image.dart';

/// Renders a single Quran page — 15 line images with a page header.
///
/// Port of the Android QuranPageView composable.
class QuranPageWidget extends StatefulWidget {
  final int pageNumber;
  final int? selectedLine;
  final ValueChanged<int>? onLineTap;

  const QuranPageWidget({
    super.key,
    required this.pageNumber,
    this.selectedLine,
    this.onLineTap,
  });

  @override
  State<QuranPageWidget> createState() => _QuranPageWidgetState();
}

class _QuranPageWidgetState extends State<QuranPageWidget> {
  late final QuranDataProvider _dataProvider;
  late List<ChapterData> _chapters;
  late int _juz;

  @override
  void initState() {
    super.initState();
    _dataProvider = QuranDataProvider.instance;
    _updatePageData();
  }

  @override
  void didUpdateWidget(covariant QuranPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber) {
      _updatePageData();
    }
  }

  void _updatePageData() {
    _chapters = _dataProvider.getChaptersForPage(widget.pageNumber);
    _juz = _dataProvider.getJuzForPage(widget.pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDF8F0), // Warm paper background
      child: Column(
        children: [
          // Page header
          _PageHeader(
            chapters: _chapters,
            pageNumber: widget.pageNumber,
            juzNumber: _juz,
          ),

          // Divider
          Container(height: 1, color: const Color(0xFFD4C5A9)),

          // 15 line images
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  children: List.generate(15, (index) {
                    final line = index + 1;
                    return Expanded(
                      child: QuranLineImage(
                        page: widget.pageNumber,
                        line: line,
                        isHighlighted: widget.selectedLine == line,
                        onTap: () => widget.onLineTap?.call(line),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Page header showing surah name, page number, and juz.
class _PageHeader extends StatelessWidget {
  final List<ChapterData> chapters;
  final int pageNumber;
  final int juzNumber;

  const _PageHeader({
    required this.chapters,
    required this.pageNumber,
    required this.juzNumber,
  });

  @override
  Widget build(BuildContext context) {
    final chapterName = chapters.isNotEmpty
        ? chapters.map((c) => c.arabicTitle).join(' - ')
        : '';

    return Container(
      color: const Color(0xFFF5ECD7),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // Juz (right side in RTL)
            Text(
              'جزء ${QuranDataProvider.toArabicNumerals(juzNumber)}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8B7355),
                fontWeight: FontWeight.w500,
              ),
            ),

            // Chapter name (center)
            Expanded(
              child: Text(
                chapterName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5C4033),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'serif',
                ),
              ),
            ),

            // Page number (left side in RTL)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8DCC8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${QuranDataProvider.toArabicNumerals(pageNumber)} / ٦٠٤',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8B7355),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
