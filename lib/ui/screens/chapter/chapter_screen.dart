import 'package:flutter/material.dart';

import '../../widgets/states/empty_view.dart';

class ChapterScreen extends StatelessWidget {
  final int chapterNumber;

  const ChapterScreen({super.key, required this.chapterNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chapitre $chapterNumber')),
      body: const Center(
        child: EmptyView(
          message: 'La fiche du chapitre arrive à la prochaine étape.',
          icon: Icons.menu_book_outlined,
        ),
      ),
    );
  }
}
