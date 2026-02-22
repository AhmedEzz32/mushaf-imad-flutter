import 'package:flutter/material.dart';
import 'package:imad_flutter/imad_flutter.dart';

void main() {
  runApp(const MushafApp());
}

class MushafApp extends StatelessWidget {
  const MushafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mushaf Imad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF8B7355),
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'serif',
      ),
      home: const MushafHomePage(),
    );
  }
}

class MushafHomePage extends StatefulWidget {
  const MushafHomePage({super.key});

  @override
  State<MushafHomePage> createState() => _MushafHomePageState();
}

class _MushafHomePageState extends State<MushafHomePage> {
  int _currentPage = 1;
  final GlobalKey<MushafPageViewState> _mushafKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ChapterIndexDrawer(
        currentPage: _currentPage,
        onChapterSelected: (page) {
          _mushafKey.currentState?.goToPage(page);
        },
      ),
      body: MushafPageView(
        key: _mushafKey,
        initialPage: 1,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
        },
        onOpenChapterIndex: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
    );
  }
}
