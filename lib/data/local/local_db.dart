import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDb {
  static const String _dbName = 'do_save_money_db.sqlite';
  static const int _dbVersion = 1;

  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        // 최초 생성 시 전체 스키마 생성
        await _createSchemaV1(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 버전 업 시 단계별 마이그레이션
        // 아직 v1이라 마이그레이션 없음
        // 예: if (oldVersion < 2) { await _migrateToV2(db); }
      },
      onConfigure: (db) async {
        // 외래키 활성화 (SQLite 기본이 OFF인 경우 많음)
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  /// v1 스키마 전체 생성 (생략 없이 전부 생성)
  static Future<void> _createSchemaV1(Database db) async {
    // groups
    await db.execute('''
CREATE TABLE groups (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  createdAt INTEGER NOT NULL,
  updatedAt INTEGER NOT NULL
);
''');

    // members
    await db.execute('''
CREATE TABLE members (
  id TEXT NOT NULL,
  groupId TEXT NOT NULL,
  displayName TEXT NOT NULL,
  role TEXT NOT NULL,
  status TEXT NOT NULL,
  createdAt INTEGER NOT NULL,
  updatedAt INTEGER NOT NULL,
  PRIMARY KEY (id, groupId),
  FOREIGN KEY (groupId) REFERENCES groups(id) ON DELETE CASCADE
);
''');

    await db.execute('CREATE INDEX idx_members_groupId ON members(groupId);');

    // stores
    await db.execute('''
CREATE TABLE stores (
  id TEXT PRIMARY KEY,
  groupId TEXT NOT NULL,
  name TEXT NOT NULL,
  createdAt INTEGER NOT NULL,
  updatedAt INTEGER NOT NULL,
  deletedAt INTEGER,
  FOREIGN KEY (groupId) REFERENCES groups(id) ON DELETE CASCADE
);
''');

    await db.execute('CREATE INDEX idx_stores_groupId ON stores(groupId);');
    await db.execute(
      'CREATE INDEX idx_stores_groupId_deletedAt ON stores(groupId, deletedAt);',
    );

    // categories
    await db.execute('''
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  groupId TEXT NOT NULL,
  name TEXT NOT NULL,
  createdAt INTEGER NOT NULL,
  updatedAt INTEGER NOT NULL,
  deletedAt INTEGER,
  FOREIGN KEY (groupId) REFERENCES groups(id) ON DELETE CASCADE
);
''');

    await db.execute(
      'CREATE INDEX idx_categories_groupId ON categories(groupId);',
    );
    await db.execute(
      'CREATE INDEX idx_categories_groupId_deletedAt ON categories(groupId, deletedAt);',
    );

    // purchases
    await db.execute('''
CREATE TABLE purchases (
  id TEXT PRIMARY KEY,
  groupId TEXT NOT NULL,
  purchasedAt INTEGER NOT NULL,
  storeId TEXT NOT NULL,
  categoryId TEXT NOT NULL,
  itemName TEXT,
  price INTEGER NOT NULL,
  createdByMemberId TEXT NOT NULL,
  createdAt INTEGER NOT NULL,
  updatedAt INTEGER NOT NULL,
  deletedAt INTEGER,
  FOREIGN KEY (groupId) REFERENCES groups(id) ON DELETE CASCADE
);
''');

    // 통계/조회 핵심 인덱스
    await db.execute(
      'CREATE INDEX idx_purchases_groupId_purchasedAt ON purchases(groupId, purchasedAt);',
    );
    await db.execute(
      'CREATE INDEX idx_purchases_store_category_date ON purchases(storeId, categoryId, purchasedAt);',
    );
    await db.execute(
      'CREATE INDEX idx_purchases_category_date ON purchases(categoryId, purchasedAt);',
    );
    await db.execute(
      'CREATE INDEX idx_purchases_groupId_deletedAt ON purchases(groupId, deletedAt);',
    );
  }
}
