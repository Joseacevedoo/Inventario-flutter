import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE inventario(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        producto TEXT,
        descripcion TEXT,
        precio REAL,
        cantidad REAL,
        stock INTEGER,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'dbinv.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Crear un nuevo producto (inventariado)
  static Future<int> createProducto(String producto, String? descripcion,
      double precio, double cantidad, int stock) async {
    final db = await SQLHelper.db();

    final data = {
      'producto': producto,
      'descripcion': descripcion,
      'precio': precio,
      'cantidad': cantidad,
      'stock': stock
    };
    final id = await db.insert('inventario', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Leer todos los productos
  static Future<List<Map<String, dynamic>>> getInventario() async {
    final db = await SQLHelper.db();
    return db.query('inventario', orderBy: "id");
  }

  // Actualizar un producto por id
  static Future<int> updateProducto(int id, String producto,
      String? descripcion, double precio, double cantidad, int stock) async {
    final db = await SQLHelper.db();

    final data = {
      'producto': producto,
      'descripcion': descripcion,
      'precio': precio,
      'cantidad': cantidad,
      'stock': stock,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('inventario', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Eliminar un producto
  static Future<void> deleteProducto(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("inventario", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Algo salio mal al intentar borrar: $err");
    }
  }
}
