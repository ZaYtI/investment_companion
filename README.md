# investment_companion

A new Flutter project.

## Lancement

L'application lit la clé de l'API Twelve Data à la compilation, depuis un fichier `env.json` qui n'est pas versionné.

1. Copier le modèle puis renseigner la clé :

   ```bash
   cp env.example.json env.json
   ```

   ```json
   {
     "TWELVE_DATA_KEY": "votre_clé"
   }
   ```

2. Lancer l'application en passant ce fichier :

   ```bash
   flutter run --dart-define-from-file=env.json
   ```

Le même argument s'ajoute à `flutter test` et `flutter build` si besoin. Dans Android Studio : *Run → Edit Configurations → Additional run args* : `--dart-define-from-file=env.json`. Sans ce fichier, la clé est vide (`Env.hasTwelveDataKey` vaut `false`).

## Séries de prix embarquées

Les séries historiques utilisées par les chapitres sont dans `assets/data/series/` (prix bruts, sans dividendes, source Twelve Data). Elles sont générées par un script, jamais modifiées à la main :

```bash
dart run tool/fetch_series.dart
```

Le script lit la clé dans `env.json` et respecte la limite de 8 requêtes par minute (environ 40 secondes). Les dates sont figées par la constante `snapshotEnd` : relancé, il produit les mêmes fichiers. Pour rafraîchir les données, avancer cette date.

| Fichier | Actif | Fréquence | Période | Chapitres |
|---|---|---|---|---|
| `spy_weekly.json` | ETF S&P 500 (SPY) | Hebdomadaire | 2007 → 2026-10 | 1, 2, 3 |
| `gold_weekly.json` | Or (XAU/USD) | Hebdomadaire | 2018 → 2026-10 | 1, 2 |
| `world_weekly.json` | ETF MSCI World (URTH) | Hebdomadaire | 2018 → 2026-10 | 1 |
| `btc_weekly.json` | Bitcoin (BTC/USD) | Hebdomadaire | 2018 → 2026-10 | 2 |
| `spy_monthly.json` | ETF S&P 500 (SPY) | Premier jour de bourse du mois | 2015 → 2026-10 | 4 |

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
