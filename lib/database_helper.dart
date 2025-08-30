import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Simple in-memory storage for web
  static final Map<String, Map<String, dynamic>> _webUsers =
      <String, Map<String, dynamic>>{};
  static final Map<String, Map<String, dynamic>> _webSessions =
      <String, Map<String, dynamic>>{};
  static int _nextUserId = 1;
  static int _nextSessionId = 1;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal() {
    // Initialize with default admin user for web
    if (kIsWeb) {
      _webUsers['admin@runnercode.com'] = {
        'id': _nextUserId++,
        'name': 'Admin User',
        'email': 'admin@runnercode.com',
        'password': 'admin123',
        'created_at': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      if (kIsWeb) {
        // For web, use simple in-memory storage
        return await _createWebDatabase();
      } else {
        // For mobile and desktop, use SQLite
        return await _initSQLiteDatabase();
      }
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<Database> _createWebDatabase() async {
    // Create a mock database for web that uses in-memory storage
    return await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        // Create tables (these won't be used, but we need them for compatibility)
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL,
            remember_me BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        print('Web database created successfully');
      },
    );
  }

  Future<Database> _initSQLiteDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'runner_code.db');
      print('Database path: $path');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onOpen: (db) {
          print('SQLite database opened successfully');
        },
      );
    } catch (e) {
      print('Error initializing SQLite database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      print('Creating database tables...');

      // Users table
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Sessions table for remember me functionality
      await db.execute('''
        CREATE TABLE sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL,
          remember_me BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Insert default admin user
      await db.insert('users', {
        'name': 'Admin User',
        'email': 'admin@runnercode.com',
        'password': 'admin123',
      });

      print('Database tables created successfully');
    } catch (e) {
      print('Error creating database tables: $e');
      rethrow;
    }
  }

  // User operations
  Future<int> insertUser(String name, String email, String password) async {
    try {
      if (kIsWeb) {
        // Use in-memory storage for web
        if (_webUsers.containsKey(email)) {
          throw Exception('Email already exists');
        }

        final user = {
          'id': _nextUserId++,
          'name': name,
          'email': email,
          'password': password,
          'created_at': DateTime.now().toIso8601String(),
        };

        _webUsers[email] = user;

        // Also persist user data in SharedPreferences for web
        final prefs = await SharedPreferences.getInstance();
        final usersJson = prefs.getString('web_users') ?? '{}';
        final Map<String, dynamic> users = Map<String, dynamic>.from(
          jsonDecode(usersJson) as Map,
        );
        users[email] = user;
        await prefs.setString('web_users', jsonEncode(users));

        print('User inserted successfully with ID: ${user['id']}');
        return user['id'] as int;
      } else {
        // Use SQLite for mobile/desktop
        final db = await database;
        print('Inserting user: $email');

        final result = await db.insert('users', {
          'name': name,
          'email': email,
          'password': password,
        });

        print('User inserted successfully with ID: $result');
        return result;
      }
    } catch (e) {
      print('Error inserting user: $e');
      rethrow;
    }
  }

  Future<bool> validateUser(String email, String password) async {
    try {
      if (kIsWeb) {
        // First try in-memory storage for web
        var user = _webUsers[email];

        // If not in memory, try to load from SharedPreferences
        if (user == null) {
          final prefs = await SharedPreferences.getInstance();
          final usersJson = prefs.getString('web_users') ?? '{}';
          final Map<String, dynamic> users = Map<String, dynamic>.from(
            jsonDecode(usersJson) as Map,
          );
          user = users[email];

          // Restore to memory if found
          if (user != null) {
            _webUsers[email] = user;
          }
        }

        final isValid = user != null && user['password'] == password;
        print('User validation result: $isValid');
        return isValid;
      } else {
        // Use SQLite for mobile/desktop
        final db = await database;
        print('Validating user: $email');

        final List<Map<String, dynamic>> result = await db.query(
          'users',
          where: 'email = ? AND password = ?',
          whereArgs: [email, password],
        );

        final isValid = result.isNotEmpty;
        print('User validation result: $isValid');
        return isValid;
      }
    } catch (e) {
      print('Error validating user: $e');
      rethrow;
    }
  }

  Future<bool> emailExists(String email) async {
    try {
      if (kIsWeb) {
        // First check in-memory storage for web
        var exists = _webUsers.containsKey(email);

        // If not in memory, check SharedPreferences
        if (!exists) {
          final prefs = await SharedPreferences.getInstance();
          final usersJson = prefs.getString('web_users') ?? '{}';
          final Map<String, dynamic> users = Map<String, dynamic>.from(
            jsonDecode(usersJson) as Map,
          );
          exists = users.containsKey(email);

          // Restore to memory if found
          if (exists) {
            _webUsers[email] = users[email];
          }
        }

        print('Email exists: $exists');
        return exists;
      } else {
        // Use SQLite for mobile/desktop
        final db = await database;
        print('Checking if email exists: $email');

        final List<Map<String, dynamic>> result = await db.query(
          'users',
          where: 'email = ?',
          whereArgs: [email],
        );

        final exists = result.isNotEmpty;
        print('Email exists: $exists');
        return exists;
      }
    } catch (e) {
      print('Error checking email existence: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      if (kIsWeb) {
        // First try in-memory storage for web
        var user = _webUsers[email];

        // If not in memory, try to load from SharedPreferences
        if (user == null) {
          final prefs = await SharedPreferences.getInstance();
          final usersJson = prefs.getString('web_users') ?? '{}';
          final Map<String, dynamic> users = Map<String, dynamic>.from(
            jsonDecode(usersJson) as Map,
          );
          user = users[email];

          // Restore to memory if found
          if (user != null) {
            _webUsers[email] = user;
          }
        }

        return user;
      } else {
        final db = await database;
        final List<Map<String, dynamic>> result = await db.query(
          'users',
          where: 'email = ?',
          whereArgs: [email],
        );
        return result.isNotEmpty ? result.first : null;
      }
    } catch (e) {
      print('Error getting user by email: $e');
      rethrow;
    }
  }

  // Session operations
  Future<void> saveUserSession(String email, bool rememberMe) async {
    try {
      if (kIsWeb) {
        // Use SharedPreferences for web to persist session across page refresh
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_email', email);
        await prefs.setBool('session_remember_me', rememberMe);
        await prefs.setString(
          'session_created_at',
          DateTime.now().toIso8601String(),
        );

        // Also keep in memory for immediate access
        _webSessions['current'] = {
          'id': _nextSessionId++,
          'email': email,
          'remember_me': rememberMe,
          'created_at': DateTime.now().toIso8601String(),
        };
        print('Session saved for: $email (web)');
      } else {
        final db = await database;
        // Clear existing sessions
        await db.delete('sessions');

        // Always save session regardless of rememberMe
        await db.insert('sessions', {
          'email': email,
          'remember_me': rememberMe ? 1 : 0,
        });
        print('Session saved for: $email (mobile)');
      }
    } catch (e) {
      print('Error saving session: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getSavedSession() async {
    try {
      if (kIsWeb) {
        // First try to get from memory
        if (_webSessions['current'] != null) {
          return _webSessions['current'];
        }

        // If not in memory, try to get from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final email = prefs.getString('session_email');

        if (email != null) {
          // Restore session from SharedPreferences
          final session = {
            'id': _nextSessionId++,
            'email': email,
            'remember_me': prefs.getBool('session_remember_me') ?? false,
            'created_at':
                prefs.getString('session_created_at') ??
                DateTime.now().toIso8601String(),
          };

          // Store back in memory
          _webSessions['current'] = session;
          print('Session restored from SharedPreferences: $email');
          return session;
        }

        return null;
      } else {
        final db = await database;
        final List<Map<String, dynamic>> result = await db.query('sessions');
        return result.isNotEmpty ? result.first : null;
      }
    } catch (e) {
      print('Error getting saved session: $e');
      rethrow;
    }
  }

  Future<void> clearSession() async {
    try {
      if (kIsWeb) {
        // Clear from memory
        _webSessions.clear();

        // Clear from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('session_email');
        await prefs.remove('session_remember_me');
        await prefs.remove('session_created_at');

        print('Session cleared (web)');
      } else {
        final db = await database;
        await db.delete('sessions');
        print('Session cleared (mobile)');
      }
    } catch (e) {
      print('Error clearing session: $e');
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteUser(String email) async {
    try {
      if (kIsWeb) {
        // Remove user from web storage
        _webUsers.remove(email);

        // Also remove from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final usersJson = prefs.getString('web_users') ?? '{}';
        final Map<String, dynamic> users = Map<String, dynamic>.from(
          jsonDecode(usersJson) as Map,
        );
        users.remove(email);
        await prefs.setString('web_users', jsonEncode(users));

        print('User deleted: $email');
      } else {
        // Remove user from SQLite database
        final db = await database;
        await db.delete('users', where: 'email = ?', whereArgs: [email]);
        print('User deleted: $email');
      }
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Close database
  Future<void> close() async {
    try {
      if (!kIsWeb) {
        final db = await database;
        await db.close();
        _database = null;
        print('Database closed');
      }
    } catch (e) {
      print('Error closing database: $e');
      rethrow;
    }
  }

  // Debug method to list all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      if (kIsWeb) {
        // First get from memory
        var users = _webUsers.values.toList();

        // If memory is empty, try to load from SharedPreferences
        if (users.isEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final usersJson = prefs.getString('web_users') ?? '{}';
          final Map<String, dynamic> usersMap = Map<String, dynamic>.from(
            jsonDecode(usersJson) as Map,
          );
          users = usersMap.values.cast<Map<String, dynamic>>().toList();

          // Restore to memory
          for (final user in users) {
            _webUsers[user['email']] = user;
          }
        }

        print('All users: $users');
        return users;
      } else {
        final db = await database;
        final result = await db.query('users');
        print('All users: $result');
        return result;
      }
    } catch (e) {
      print('Error getting all users: $e');
      rethrow;
    }
  }
}
