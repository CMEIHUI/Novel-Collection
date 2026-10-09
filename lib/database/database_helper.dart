// Conditional export: re-export the platform-specific implementation so callers
// can use `DatabaseHelper` transparently.
export 'database_helper_io.dart'
    if (dart.library.html) 'database_helper_web.dart';
