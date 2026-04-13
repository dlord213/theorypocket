import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:theorypocket/features/progression_builder/models/song_model.dart';

class SongDatabase {
  SongDatabase._();
  static final SongDatabase instance = SongDatabase._();

  static Database? _db;

  Future<Database> get _database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'theorypocket.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE songs (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          title       TEXT    NOT NULL,
          key         TEXT    NOT NULL,
          chords      TEXT    NOT NULL,
          created_at  INTEGER NOT NULL
        )
      '''),
    );
  }

  Future<List<Song>> fetchAll() async {
    final db = await _database;
    final rows = await db.query('songs', orderBy: 'created_at DESC');
    return rows.map(Song.fromMap).toList();
  }

  Future<Song> insert(Song song) async {
    final db = await _database;
    final id = await db.insert('songs', song.toMap());
    return song.copyWith(id: id);
  }

  Future<void> update(Song song) async {
    final db = await _database;
    await db.update(
      'songs',
      song.toMap(),
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _database;
    await db.delete('songs', where: 'id = ?', whereArgs: [id]);
  }
}
