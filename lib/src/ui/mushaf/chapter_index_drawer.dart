import 'package:flutter/material.dart';
import '../../data/quran/quran_data_provider.dart';
import '../../data/quran/quran_metadata.dart';

/// Drawer showing all 114 surahs for quick navigation.
///
/// Each surah shows its Arabic title, English title, and starting page.
/// Tapping a surah navigates to its starting page.
class ChapterIndexDrawer extends StatelessWidget {
  /// Callback when a chapter is selected, passes the starting page number.
  final ValueChanged<int> onChapterSelected;

  /// Currently displayed page number (to highlight the active chapter).
  final int currentPage;

  const ChapterIndexDrawer({
    super.key,
    required this.onChapterSelected,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final dataProvider = QuranDataProvider.instance;
    final chapters = dataProvider.getAllChapters();
    final currentChapters = dataProvider.getChaptersForPage(currentPage);
    final currentChapterNumbers = currentChapters.map((c) => c.number).toSet();

    return Drawer(
      backgroundColor: const Color(0xFFFDF8F0),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            decoration: const BoxDecoration(color: Color(0xFF8B7355)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'فهرس السور',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  'Chapter Index · ${chapters.length} Surahs',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Search/filter area
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  'Page ${QuranDataProvider.toArabicNumerals(currentPage)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8B7355),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.swipe, size: 16, color: Color(0xFF8B7355)),
                const SizedBox(width: 4),
                const Text(
                  'Tap to jump',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8B7355)),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFD4C5A9)),

          // Chapter list
          Expanded(
            child: ListView.builder(
              itemCount: chapters.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final isActive = currentChapterNumbers.contains(chapter.number);

                return _ChapterListItem(
                  chapter: chapter,
                  isActive: isActive,
                  onTap: () {
                    onChapterSelected(chapter.startPage);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterListItem extends StatelessWidget {
  final ChapterData chapter;
  final bool isActive;
  final VoidCallback onTap;

  const _ChapterListItem({
    required this.chapter,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFFEDE5D3) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Chapter number badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? const Color(0xFF8B7355)
                      : const Color(0xFFF5ECD7),
                  border: Border.all(color: const Color(0xFFD4C5A9), width: 1),
                ),
                child: Center(
                  child: Text(
                    '${chapter.number}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : const Color(0xFF5C4033),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Chapter details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.arabicTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: const Color(0xFF5C4033),
                        fontFamily: 'serif',
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      chapter.englishTitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF8B7355).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Verse count & page number
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'p. ${chapter.startPage}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8B7355),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${chapter.versesCount} ayat',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF8B7355).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
