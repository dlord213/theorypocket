import 'dart:convert';

class Song {
  final int? id;
  final String title;
  final String key;
  final List<String> chords;
  final DateTime createdAt;

  const Song({
    this.id,
    required this.title,
    required this.key,
    required this.chords,
    required this.createdAt,
  });

  Song copyWith({
    int? id,
    String? title,
    String? key,
    List<String>? chords,
    DateTime? createdAt,
  }) =>
      Song(
        id: id ?? this.id,
        title: title ?? this.title,
        key: key ?? this.key,
        chords: chords ?? this.chords,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'key': key,
        'chords': jsonEncode(chords),
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Song.fromMap(Map<String, dynamic> map) => Song(
        id: map['id'] as int,
        title: map['title'] as String,
        key: map['key'] as String,
        chords: (jsonDecode(map['chords'] as String) as List).cast<String>(),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      );
}
