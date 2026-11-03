import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/asset.dart';
import '../models/price_series.dart';
import '../services/calc/portfolio.dart';
import '../services/quiz_generator.dart';
import 'simulation_providers.dart';

final quizQuestionsProvider = FutureProvider<List<ComparisonQuestion>>((
  ref,
) async {
  final repository = ref.watch(priceRepositoryProvider);
  final seriesByAsset = <QuizAsset, PriceSeries>{};
  for (final asset in Asset.all) {
    if (asset.id == cashId) continue;
    final quizAsset = QuizAsset(
      id: asset.id,
      name: asset.name,
      category: asset.category,
    );
    seriesByAsset[quizAsset] = await repository.getSeries(asset.id);
  }
  return generateQuestions(seriesByAsset, Random());
});
