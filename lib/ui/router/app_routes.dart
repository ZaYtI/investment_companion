abstract final class AppRoutes {
  static const welcome = '/bienvenue';
  static const map = '/carte';
  static const explore = '/explorer';
  static const simulations = '/simulations';
  static const trophies = '/trophees';
  static const gallery = '/galerie';
  static const newSimulation = '$simulations/nouvelle';
  static const composeSimulation = '$simulations/portefeuille';
  static const simulationResult = '$simulations/resultat';

  static String chapter(int number) => '$map/chapitre/$number';

  static String chapterContext(int chapterNumber) =>
      '${chapter(chapterNumber)}/contexte';

  static String level(int chapterNumber, int levelIndex) =>
      '${chapter(chapterNumber)}/niveau/$levelIndex';
}
