import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/chapters_data.dart';
import '../../../models/glossary_term.dart';
import '../../../models/lesson_page.dart';
import '../../../models/level_type.dart';
import '../../../providers/progress_provider.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/states/error_view.dart';
import 'example_view.dart';
import 'explanation_view.dart';
import 'hook_view.dart';
import 'lesson_result_view.dart';
import 'quiz_view.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final int chapterNumber;

  const LessonScreen({super.key, required this.chapterNumber});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  late final Future<List<LessonPage>> _pages = loadLessonPages(
    widget.chapterNumber,
  );
  late final Future<Map<String, GlossaryTerm>> _glossary = loadGlossary();

  var _pageIndex = 0;
  var _quizAttempt = 0;
  int? _quizScore;

  void _goToNextPage() {
    setState(() => _pageIndex++);
  }

  void _showResult(int score, int passingScore) {
    setState(() => _quizScore = score);
    if (score >= passingScore) {
      ref
          .read(progressProvider.notifier)
          .completeLevel(
            widget.chapterNumber,
            LevelType.understand.index,
            xpEarned: LevelType.understand.xp,
          );
    }
  }

  void _retryQuiz() {
    setState(() {
      _quizScore = null;
      _quizAttempt++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_pages, _glossary]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: ErrorView(
                message: 'Le contenu de ce chapitre arrive bientôt.',
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final pages = snapshot.data![0] as List<LessonPage>;
        final glossary = snapshot.data![1] as Map<String, GlossaryTerm>;
        return _buildLesson(pages, glossary);
      },
    );
  }

  Widget _buildLesson(
    List<LessonPage> pages,
    Map<String, GlossaryTerm> glossary,
  ) {
    final page = pages[_pageIndex];
    final isShowingResult = _quizScore != null;
    final progress = isShowingResult
        ? 1.0
        : (_pageIndex + 1) / (pages.length + 1);
    final showContinueButton =
        !isShowingResult && page.kind != LessonPageKind.quiz;

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () => context.pop()),
        title: LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'CHAPITRE ${widget.chapterNumber} · '
                      '${LevelType.understand.title.toUpperCase()}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 12),
                    isShowingResult
                        ? LessonResultView(
                            correctAnswers: _quizScore!,
                            totalQuestions: page.questions.length,
                            passingScore: page.passingScore,
                            xp: LevelType.understand.xp,
                            onRetry: _retryQuiz,
                            onBack: () => context.pop(),
                          )
                        : _buildPage(page, glossary),
                  ],
                ),
              ),
            ),
            if (showContinueButton)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                child: PrimaryButton(
                  text: 'Continuer',
                  onPressed: _goToNextPage,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(LessonPage page, Map<String, GlossaryTerm> glossary) {
    switch (page.kind) {
      case LessonPageKind.hook:
        return HookView(key: ValueKey(_pageIndex), page: page);
      case LessonPageKind.explanation:
        return ExplanationView(page: page, glossary: glossary);
      case LessonPageKind.example:
        return ExampleView(key: ValueKey(_pageIndex), page: page);
      case LessonPageKind.quiz:
        return QuizView(
          key: ValueKey(_quizAttempt),
          page: page,
          onFinished: (score) => _showResult(score, page.passingScore),
        );
    }
  }
}
