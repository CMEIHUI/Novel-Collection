import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializePlatformFfi() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
