class BibleBook {
  final int id;
  final String name;
  final String amharicName;
  final String testament;
  final int chapters;
  final String abbreviation;

  BibleBook({
    required this.id,
    required this.name,
    required this.amharicName,
    required this.testament,
    required this.chapters,
    required this.abbreviation,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      id: json['id'],
      name: json['name'],
      amharicName: json['amharicName'],
      testament: json['testament'],
      chapters: json['chapters'],
      abbreviation: json['abbreviation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amharicName': amharicName,
      'testament': testament,
      'chapters': chapters,
      'abbreviation': abbreviation,
    };
  }
}
