class KeyMoment {
  final DateTime date;
  final String title;
  final String subtitle;

  const KeyMoment({
    required this.date,
    required this.title,
    required this.subtitle,
  });

  static final all = [
    KeyMoment(
      date: DateTime(2020, 3, 2),
      title: 'Mars 2020 · Covid',
      subtitle: '−34 % en 23 séances',
    ),
    KeyMoment(
      date: DateTime(2008, 9, 15),
      title: 'Septembre 2008 · Lehman',
      subtitle: "La crise financière s'accélère",
    ),
    KeyMoment(
      date: DateTime(2000, 3, 6),
      title: 'Mars 2000 · Bulle internet',
      subtitle: 'Le sommet avant deux ans de baisse',
    ),
    KeyMoment(
      date: DateTime(2022, 1, 3),
      title: 'Janvier 2022 · Taux et inflation',
      subtitle: 'Actions et obligations baissent ensemble',
    ),
  ];
}
