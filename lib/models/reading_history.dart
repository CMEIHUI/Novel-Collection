class ReadingHistory {
  final int? id;
  final int userId;
  final int novelId;
  final int pagesRead;
  final String date;

  const ReadingHistory({
    this.id,
    required this.userId,
    required this.novelId,
    required this.pagesRead,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'novelId': novelId,
      'pagesRead': pagesRead,
      'date': date,
    };
  }

  factory ReadingHistory.fromMap(Map<String, dynamic> map) {
    return ReadingHistory(
      id: map['id'],
      userId: map['userId'],
      novelId: map['novelId'],
      pagesRead: map['pagesRead'],
      date: map['date'],
    );
  }
}
