class Favorite {
  final int? id;
  final int userId;
  final int novelId;

  const Favorite({this.id, required this.userId, required this.novelId});

  Map<String, dynamic> toMap() {
    return {'id': id, 'userId': userId, 'novelId': novelId};
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'],
      userId: map['userId'],
      novelId: map['novelId'],
    );
  }
}
