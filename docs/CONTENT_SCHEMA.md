# Schéma du contenu

Le contenu pédagogique vit dans `assets/content/`, pas dans le code des widgets :

| Fichier | Contenu |
|---|---|
| `chapter_01.json` … `chapter_07.json` | Un chapitre et ses 3 niveaux |
| `glossary.json` | Les termes du glossaire |
| `daily_challenges.json` | Les scénarios du défi du jour |

Règles communes : textes au vouvoiement ; identifiants hiérarchiques et stables (`ch1`, `ch1.l2`, `ch1.l1.q3`), utilisés pour sauvegarder la progression ; les calculs restent dans le code Dart, le JSON ne dit que quoi afficher ; les notes des défis sont dans le JSON, les poids (40 / 35 / 25) et les seuils d'étoiles (50 / 80) dans le code. `chapter_01.json` est l'exemple de référence.

## Chapitre

| Champ | Type | Description |
|---|---|---|
| `id` | `string` | `ch1` à `ch7` |
| `number` | `int` | 1 à 7, ordre de déblocage |
| `title` | `string` | Titre affiché sur la carte |
| `period` | `Period?` | Époque réelle, `null` pour le chapitre 1 |
| `idea` | `string` | Idée à retenir |
| `typicalMistake` | `string` | Erreur typique corrigée |
| `series` | `string[]` | Identifiants des séries de `assets/data/series/` utilisées |
| `context` | `Context?` | Écran « Contexte de l'époque », `null` si pas de date |
| `levels` | `Level[3]` | Dans l'ordre : `understand`, `simulate`, `challenge` |

`Period` : `{ "label": "2007 à 2009", "start": "2007-10-01", "end": "2009-03-31" }`

`Context` : `{ "facts": [{ "icon": "bank", "text": "…" }], "figures": "…", "afterwards": "…" }` ; `facts` contient 3 éléments, `afterwards` (« Et ensuite ? ») n'est affiché qu'après le défi.

## Niveau

Champs communs : `id`, `type`, `title`, `xp` (20, 60, 60).

### `understand`

`screens` : liste d'écrans, chacun avec `id`, `kind`, `title`, `text`, `pip` (phrase de Pip ou `null`) et `terms` (identifiants du glossaire soulignés dans le texte).

| `kind` | Champs en plus |
|---|---|
| `hook` | `options: string[]`, cartes à toucher, non notées |
| `explanation` | aucun |
| `example` | `steps: [{ "label", "value" }]`, nombres affichés l'un après l'autre |
| `quiz` | `passingScore: int`, `questions: Question[]` |

`Question` : `{ "id", "question", "choices": string[], "answerIndex": int, "explanation" }` ; l'explication est affichée que la réponse soit juste ou fausse.

### `simulate`

| Champ | Type | Description |
|---|---|---|
| `instruction` | `string` | Consigne |
| `simulator` | `string` | Simulateur à ouvrir (tableau ci-dessous) |
| `settings` | `object` | Réglages propres au simulateur |
| `readingQuestion` | `Question` | Question de lecture guidée |
| `notes` | `string[]` | Mentions affichées (prix bruts, pas de frais…) |

| `simulator` | Chapitre | `settings` |
|---|---|---|
| `singleAsset` | 1 | `assets`, `amount { min, step, max }`, `periodsInYears` |
| `riskComparison` | 2 | `assets`, `startYears`, `amountPerAsset` |
| `drawdownTimeline` | 3 | `asset`, `entryDates`, `horizons: [{ id, label }]`, `markers: [{ date, label }]` |
| `dca` | 4 | `asset`, `defaultStart`, `startRange { from, to }`, `monthly { min, max, step, default }` |
| `portfolioReplay` | 5 | `entryDates`, `capital`, `presets: [{ id, label, weights }]`, `assets` |
| `dailyReplay` | 6 | `asset`, `start`, `capital`, `highlightedDays`, `jumps: [{ label, date }]` |
| `goalScenarios` | 7 | `rates`, `target`, `monthly`, `years` (chacun `{ min, max, default }`) |

### `challenge`

`challenge` : objet avec `kind`, `situation`, `keyMessage`, et les champs du type.

| `kind` | Chapitre | Champs |
|---|---|---|
| `guess` | 1 | `choices`, `answerIndex`, `starsByAttempt: [3, 2, 1]`, `explanation` |
| `riskProfile` | 2 | `profileQuestions: Question[]` (sans `answerIndex`), `assets`, `windowYears`, `bands: [{ id, maxVolatility }]` |
| `decision` | 3, 6 | `plans: [{ id, label }]`, `planFromLevel` (identifiant du niveau qui a fixé le plan, ou `null`), `choices: [{ id, label, scores: { <planId>: { coherence, prudence, composure } } }]`, `timerSeconds` (`null` sans chrono), `afterwards` |
| `monthlyPlan` | 4 | `monthlyAmount`, `months: string[]` (`2022-04` …), `decisions: [{ id, label, multiplier }]` |
| `portfolioConstraint` | 5 | `period { start, end }`, `maxDrawdown`, `minEquityWeight`, `equityAssets`, `attempts`, `starsByAttempt` |
| `goalPlan` | 7 | `target`, `monthly { min, max }`, `years { min, max }`, `rate`, `stressTestStart`, `stars: [{ stars, condition }]` |

## Glossaire

`glossary.json` : `{ "terms": [{ "id", "term", "definition", "chapter" }] }`. Chaque identifiant cité dans un `terms` de chapitre doit exister ici.
