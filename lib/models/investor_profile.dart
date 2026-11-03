enum InvestorProfile {
  curious('Curieux', 'Je découvre les bases'),
  careful('Prudent', 'Je veux comprendre le risque'),
  ambitious('Ambitieux', 'Je vise un objectif chiffré');

  const InvestorProfile(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
