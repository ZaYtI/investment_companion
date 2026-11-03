enum LevelType {
  understand('Comprendre', 20),
  simulate('Simuler', 60),
  challenge('Défi', 60);

  const LevelType(this.title, this.xp);

  final String title;
  final int xp;
}
