abstract final class AppRoutes {
  static const welcome = '/bienvenue';
  static const map = '/carte';
  static const explore = '/explorer';
  static const simulations = '/simulations';
  static const trophies = '/trophees';
  static const gallery = '/galerie';

  static String chapter(int number) => '$map/chapitre/$number';
}
