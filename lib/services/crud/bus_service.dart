import 'dart:async';
//import 'package:flutter/cupertino.dart';
import 'package:demo2/services/crud/crud_exceptions.dart';
import 'package:demo2/services/crud/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
//import 'dart:html';

class BusService extends Services {
  Database? _db;

  List<DatabaseBus> _bus = [];

  DatabaseUser? _user;

  late final StreamController<List<DatabaseBus>> _busStreamController;

  static final BusService _sharedBus = BusService._sharedInstance();
  BusService._sharedInstance() {
    _busStreamController = StreamController<List<DatabaseBus>>.broadcast(
      onListen: () {
        _busStreamController.sink.add(_bus);
      },
    );
  }
  factory BusService() => _sharedBus;

  Stream<List<DatabaseBus>> get allBus => _busStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheBus() async {
    final allbus = await getAllBus();
    _bus = allbus.toList();
    _busStreamController.add(_bus);
  }

  Future<DatabaseBus> createBus({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const busNo = '';
    const acOrNonAc = '';
    const route = '';
    const perSeatPrice = '';
    const departure = '';
    const arrive = '';

    // create the note
    final busId = await db.insert(busTable, {
      acOrNonAcColumn: acOrNonAc,
      busNoColumn: busNo,
      routeColumn: route,
      perSeatPriceColumn: perSeatPrice,
      departureColumn: departure,
      arriveColumn: arrive,
      isSyncedWithCloudColumn: 1,
    });

    final bus = DatabaseBus(
      id: busId,
      acOrNonAc: acOrNonAc,
      busNo: busNo,
      route: route,
      perSeatPrice: perSeatPrice,
      departure: departure,
      arrive: arrive,
      isSyncedWithCloud: true,
    );
    _bus.add(bus);
    _busStreamController.add(_bus);
    return bus;
  }

  Future<Iterable<DatabaseBus>> getAllBus() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final buses = await db.query(busTable);

    return buses.map((busRow) => DatabaseBus.fromRow(busRow));
  }

  Future<DatabaseBus> getBus({required int id}) async {
    final db = _getDatabaseOrThrow();
    final buses = await db.query(
      busTable,
      limit: 1,
      where: 'busNo = ?',
      whereArgs: [id],
    );

    if (buses.isEmpty) {
      throw CouldNotFindBus();
    } else {
      final bus = DatabaseBus.fromRow(buses.first);
      _bus.removeWhere((bus) => bus.id == id);
      _bus.add(bus);
      _busStreamController.add(_bus);
      return bus;
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  @override
  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  @override
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //Empty
    }
  }

  @override
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      /// creating user table
      await db.execute(createUserTable);

      /// creating Bus table
      await db.execute(createBusTable);

      await _cacheBus();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Future<DatabaseBus> updateBus({
    required DatabaseBus bus,
    required String acOrNonAc,
    required String busNo,
    required String route,
    required String perSeatPrice,
    required String departure,
    required String arrive,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getBus(id: bus.id);
    final updatesCount = await db.update(
      busTable,
      {
        acOrNonAcColumn: acOrNonAc,
        busNoColumn: busNo,
        routeColumn: route,
        perSeatPriceColumn: perSeatPrice,
        departureColumn: departure,
        arriveColumn: arrive,
        isSyncedWithCloudColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [bus.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedBus = await getBus(id: bus.id);
      _bus.removeWhere((bus) => bus.id == updatedBus.id);
      _bus.add(updatedBus);
      _busStreamController.add(_bus);
      return updatedBus;
    }
  }

  Future<Iterable> fetchAllBus() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final bus = await db.query(
      busTable,
    );
    return bus.map((n) => DatabaseNote.fromRow(n));
  }

  Future<int> deleteAllBuses() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(busTable);
    _bus = [];
    _busStreamController.add(_bus);
    return numberOfDeletions;
  }

  Future<void> deleteBus({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      busTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _bus.removeWhere((bus) => bus.id == id);
      _busStreamController.add(_bus);
    }
  }
}
