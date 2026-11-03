import 'package:flutter/material.dart';

import '../../../data/chapters_data.dart';
import '../../../models/glossary_term.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/states/error_view.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  late final Future<Map<String, GlossaryTerm>> _glossary = loadGlossary();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Glossaire')),
      body: FutureBuilder(
        future: _glossary,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: ErrorView(message: 'Impossible de charger le glossaire.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final terms = snapshot.data!.values.toList()
            ..sort((a, b) => a.term.compareTo(b.term));
          return ListView(
            padding: EdgeInsets.fromLTRB(
              22,
              22,
              22,
              22 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              for (final term in terms) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        term.term,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(term.definition, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}
