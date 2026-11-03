class ChallengeLevel {
  final String kind;
  final String situation;
  final String keyMessage;
  final Map<String, dynamic> data;

  const ChallengeLevel({
    required this.kind,
    required this.situation,
    required this.keyMessage,
    required this.data,
  });

  factory ChallengeLevel.fromJson(Map<String, dynamic> json) {
    final challenge = json['challenge'] as Map<String, dynamic>;
    return ChallengeLevel(
      kind: challenge['kind'] as String,
      situation: challenge['situation'] as String,
      keyMessage: challenge['keyMessage'] as String,
      data: challenge,
    );
  }
}
