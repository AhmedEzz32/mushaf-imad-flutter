import 'package:flutter/material.dart';
import '../../data/quran/quran_data_provider.dart';
import '../../data/quran/quran_metadata.dart';
import '../../data/quran/verse_data_provider.dart';
import 'quran_line_image.dart';

/// Renders a single Quran page — 15 line images with a page header.
///
/// Port of the Android QuranPageView composable.
/// Supports verse-level selection and highlighting.
class QuranPageWidget extends StatefulWidget {
  final int pageNumber;

  /// Currently selected verse (chapterNumber * 1000 + verseNumber).
  /// null means no selection.
  final int? selectedVerseKey;

  /// Called when a verse is tapped. Provides (chapterNumber, verseNumber).
  final void Function(int chapterNumber, int verseNumber)? onVerseTap;

  const QuranPageWidget({
    super.key,
    required this.pageNumber,
    this.selectedVerseKey,
    this.onVerseTap,
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
    final verseProvider = VerseDataProvider.instance;
    final pageVerses = verseProvider.getVersesForPage(widget.pageNumber);

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

                    // Find markers ending on this line
                    final markers = pageVerses
                        .where(
                          (v) =>
                              v.marker1441 != null &&
                              v.marker1441!.line == line,
                        )
                        .toList();

                    // Find verses that occupy this line
                    final versesOnLine = pageVerses
                        .where((v) => v.occupiesLine(line))
                        .toList();

                    // Calculate exact highlight regions for the selected verse
                    final highlights = <VerseHighlightData>[];
                    if (widget.selectedVerseKey != null) {
                      final selectedVerse = versesOnLine
                          .where(
                            (v) =>
                                v.chapter * 1000 + v.number ==
                                widget.selectedVerseKey,
                          )
                          .firstOrNull;

                      if (selectedVerse != null) {
                        highlights.addAll(
                          selectedVerse.highlights1441.where(
                            (h) => h.line == line,
                          ),
                        );
                      }
                    }

                    return Expanded(
                      child: QuranLineImage(
                        page: widget.pageNumber,
                        line: line,
                        highlights: highlights,
                        markers: markers,
                        onTapUpExact: (tapRatio) {
                          if (widget.onVerseTap == null || versesOnLine.isEmpty)
                            return;

                          PageVerseData? target;

                          // 1. Precise hit test against exact verse bounds
                          for (final verse in versesOnLine) {
                            final hList = verse.highlights1441.where(
                              (h) => h.line == line,
                            );
                            for (final h in hList) {
                              if (tapRatio >= h.left && tapRatio <= h.right) {
                                target = verse;
                                break;
                              }
                            }
                            if (target != null) break;
                          }

                          // 2. Fallback if tapped on empty space or gap between verses
                          if (target == null) {
                            target = markers.isNotEmpty
                                ? markers.last
                                : versesOnLine.last;
                          }

                          print(
                            "Calling onVerseTap with chapter: ${target?.chapter}, verse: ${target?.number}",
                          );
                          widget.onVerseTap!(target!.chapter, target.number);
                        },
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
