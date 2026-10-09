class Novel {
  int? id;
  String title;
  String author;
  String genre;
  double rating;
  String review;
  String? coverImage;
  String? content;
  bool isFavorite;
  int totalPages;
  int pagesRead;
  String? lastOpenedChapter;

  Novel({
    this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.rating,
    required this.review,
    this.coverImage,
    this.content,
    this.isFavorite = false,
    this.totalPages = 0,
    this.pagesRead = 0,
    this.lastOpenedChapter,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'rating': rating,
      'review': review,
      'coverImage': coverImage,
      'content': content,
      'isFavorite': isFavorite ? 1 : 0,
      'totalPages': totalPages,
      'pagesRead': pagesRead,
      'lastOpenedChapter': lastOpenedChapter,
    };
  }

  factory Novel.fromMap(Map<String, dynamic> map) {
    return Novel(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      genre: map['genre'],
      rating: map['rating']?.toDouble() ?? 0.0,
      review: map['review'],
      coverImage: map['coverImage'],
      content: map['content'],
      isFavorite: map['isFavorite'] == 1 || map['isFavorite'] == true,
      totalPages: map['totalPages'] ?? 0,
      pagesRead: map['pagesRead'] ?? 0,
      lastOpenedChapter: map['lastOpenedChapter'],
    );
  }
}
