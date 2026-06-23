import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Model/obra_model.dart';

class DataBaseHelper {
  static final DataBaseHelper instance = DataBaseHelper._init();
  static Database? _database;

  DataBaseHelper._init();

  Future<Database> get database async {
    if (_database !=null) return _database!;
    _database = await _initDB("kiwi_acervo.db");
    return _database!;
  }
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async{
    await db.execute('''
        CREATE TABLE obras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        autor TEXT NOT NULL,
        editora TEXT NOT NULL,
        tipo TEXT NOT NULL,
        estado TEXT NOT NULL,
        total INTEGER NOT NULL,
        tenho INTEGER NOT NULL,
        lidos INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertObra(Obra obra) async {
    final db = await instance.database;
    return await db.insert('obras', obra.toMap());
  }

   Future<int> deleteObra(int id) async {
    final db = await instance.database;
    
    return await db.delete(
      'obras',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
   Future<List<Obra>> getObras() async
  {
    final db = await instance.database;

    final resultado = await db.query('obras' , orderBy: 'nome ASC');

    return resultado.map((json) => Obra.fromMap(json)).toList();
  }

  Future<Map<String, int>> getResumoEstatisticas() async {
    final db = await instance.database;


    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        COUNT(id) as titulos,
        COALESCE(SUM(total), 0) as totais,
        COALESCE(SUM(tenho), 0) as tenho,
        COALESCE(SUM(lidos), 0) as lidos
      FROM obras
    ''');

    return {
      'titulos': result.first['titulos'] as int,
      'totais': result.first['totais'] as int,
      'tenho': result.first['tenho'] as int,
      'lidos': result.first['lidos'] as int,
    };
  }
}