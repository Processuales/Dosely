// Web stub file for dart:io classes
// This file provides stub implementations that allow code to compile on web
// while the actual dart:io implementations are used on mobile/desktop

import 'dart:typed_data';

/// Stub File class for web platform
/// This class is never actually used on web - it's guarded by kIsWeb checks
class File {
  final String path;
  File(this.path);

  Future<bool> exists() async => false;
  Future<void> delete() async {}
  Future<Uint8List> readAsBytes() async => Uint8List(0);
}

/// Stub Directory class for web platform
class Directory {
  final String path;
  Directory(this.path);

  Future<bool> exists() async => false;
  Future<void> create({bool recursive = false}) async {}
}
