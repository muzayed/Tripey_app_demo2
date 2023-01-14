
import 'dart:async';

import 'package:demo2/services/crud/crud_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' ;
import 'package:path/path.dart' show join; 



class Services {
  Database? _db;

  Future<DatabaseUser> createUser({required String email}) async{
    await _ensureDbIsOpen();
    final db= _getDatabaseOrThrow();
    final results= await db.query(userTable,
    limit: 1,
    where: 'email=?',
    whereArgs: [email.toLowerCase()]);
    if (results.isNotEmpty){
      throw UserAlreadyExists();
    }
    final userId=await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(id: userId, email: email);

  }
    Future<DatabaseUser> getUser({required String email}) async{
    await _ensureDbIsOpen();
    final db= _getDatabaseOrThrow();
    final results= await db.query(userTable,
    limit: 1,
    where: 'email=?',
    whereArgs: [email.toLowerCase()]);
    if (results.isEmpty){
      throw CouldNotFindUser();
    }else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<void> deleteUser({required String email})async {
    await _ensureDbIsOpen();
    final db= _getDatabaseOrThrow();
    final deletedCount= await db.delete(userTable,
    where: 'email=?',
    whereArgs: [email.toLowerCase()],);
    if (deletedCount!= 1){
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow (){
    final db= _db;
    if (db== null){
      throw DatabaseIsNotOpenException();
    }else {return db;}
  }

  Future<void> open() async{
    if (_db!=null){
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath= await getApplicationDocumentsDirectory();
      final dbPath= join (docsPath.path,dbName);
      final db= await openDatabase(dbPath);
      _db=db;
      await db.execute(createUserTable);
      await db.execute(createNoteTable);
      //await _cacheNotes();
    }on MissingPlatformDirectoryException{UnableToGetDocumentDirectory() ;}
  }
Future<void> close() async{
  final db=_db;
  if (db==null){
    throw DatabaseIsNotOpenException();
  } else {
    await db.close();
     _db=null;
  }
}
Future<void> _ensureDbIsOpen() async{
  try{
    await open();
  }on DatabaseAlreadyOpenException{}
}

}


@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id, 
    required this.email,
    });
  DatabaseUser.fromRow(Map<String, Object?>map): id= map[idColumn] as int, email= map[emailColumn] as String;
  @override
  String toString() => 'Person, ID= $id, Email= $email';
  
  @override 
  bool operator== (covariant DatabaseUser other)=>id ==other.id;
  @override
  int get hashCode=> id.hashCode;


}
@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud
    });
  DatabaseNote.fromRow(Map<String, Object?>map): id= map[idColumn] as int,
   userId= map[userIdColumn] as int,
   text= map[textColumn] as String,
   isSyncedWithCloud= (map[isSyncedWithCloudColumn] as int)==1? true: false ;

   @override
  String toString() => 'Note, ID= $id, userId= $userId, isSyncedWithCloud=$isSyncedWithCloud'; 

  @override 
  bool operator== (covariant DatabaseNote other)=>id ==other.id;
  @override
  int get hashCode=> id.hashCode;
}
@immutable
class DatabaseBus {
  final int id;
  final String acOrNonAc;
  final String busNo;
  final String route;
  final String perSeatPrice;
  final String departure;
  final String arrive;
  final bool isSyncedWithCloud;

  DatabaseBus({
    required this.id,
    required this.acOrNonAc,
    required this.busNo,
    required this.route,
    required this.perSeatPrice,
    required this.departure,
    required this.arrive,
    required this.isSyncedWithCloud,
  });

  DatabaseBus.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        acOrNonAc = map[acOrNonAcColumn] as String,
        busNo = map[busNoColumn] as String,
        route = map[routeColumn] as String,
        perSeatPrice = map[perSeatPriceColumn] as String,
        departure = map[departureColumn] as String,
        arrive = map[arriveColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Bus, Bus No = $busNo, Bus type = $acOrNonAc, route = $route';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName= 'notes.db';
const userTable='user';
const noteTable='note';
const idColumn = 'id';
const emailColumn= 'email';
const userIdColumn= 'user_id';
const textColumn='text';
const isSyncedWithCloudColumn='is_synced_with_cloud';
const busTable='bus';
const acOrNonAcColumn = "ac_or_non_ac";
const busIdColumn = 'bus_id';
const busNoColumn = 'bus_no';
const routeColumn = 'route';
const perSeatPriceColumn = 'per_seat_price';
const departureColumn = 'departure';
const arriveColumn = 'arrive';


const createUserTable= ''' CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );
''';
const createNoteTable= ''' CREATE TABLE IF NOT EXISTS  "note" (
              "id"	INTEGER NOT NULL,
              "user_id"	INTEGER NOT NULL,
              "text"	TEXT,
              "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
              PRIMARY KEY("id" AUTOINCREMENT)
            );
''';
const createBusTable = '''
      CREATE TABLE IF NOT EXISTS "bus" (
        "id"    INTEGER NOT NULL,
        "ac_or_non_ac"    TEXT,
        "bus_no"    TEXT NOT NULL UNIQUE,
        "route"    TEXT,
        "per_seat_price"    TEXT,
        "departure"    TEXT,
        "arrive"    TEXT,

        "is_synced_with_cloud"    INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT)
      );
      ''';