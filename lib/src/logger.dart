import 'dart:async' show StreamController;

import 'config.dart';
import 'file.dart';
import 'util.dart';
import 'package:logging/logging.dart';

/// Special key to turn on logging for all levels ALL.
/// Special key to turn off all logging OFF.
/// Key for highly detailed tracing FINEST.
/// Key for fairly detailed tracing FINER.
/// Key for tracing information FINE.
/// Key for static configuration messages CONFIG.
/// Key for informational messages INFO.
/// Key for potential problems WARNING.
/// Key for serious failures SEVERE.
/// Key for extra debugging loudness SHOUT.

late final Logger logger;

void initLogger( ) {
    final logFile = GenericFile( createEntityName( "logs", config[ 'app_name' ], ext: "log", pattern: "yyyyMMdd" ) );
    Logger.root.level = _getLevel( config[ 'log_level' ] );
    Logger.root.onRecord.listen( 
        ( record ) {
            var msg = '${record.time}: ${record.level.name}: ${record.message}\n';
            logFile.writeString( msg, mode: GenericFile.APPEND );
            if( record.stackTrace != null ) {
                logFile.writeString( record.stackTrace.toString( ), mode: GenericFile.APPEND );
            }
            notification.add( record );
        }
    );
    logger = Logger( config[ 'app_name' ] );
}

Level _getLevel( String level ) {
    switch( level ) {
        case 'ALL':
            return Level.ALL;
        case 'OFF':
            return Level.OFF;
        case 'INFO':
            return Level.INFO;
        case 'CONFIG':
            return Level.CONFIG;
        case 'FINE':
            return Level.FINE;
        case 'FINER':
            return Level.FINER;
        case 'FINEST':
            return Level.FINEST;
        case 'SEVERE':
            return Level.SEVERE;
        case 'SHOUT':
            return Level.SHOUT;
        case 'WARNING':
            return Level.WARNING;
        default:
            return Level.ALL;
    }
}

/**
 * The notification center accumulates messages to show in application
 */
class NotificationCenter {
    NotificationCenter._( );

    final _controller = StreamController< LogRecord >.broadcast( );
    final List< LogRecord > _records = [];

    List< LogRecord > get records => List.unmodifiable( _records );
    Stream< LogRecord > get stream => _controller.stream;

    void add( LogRecord record ) {
        _records.add( record );
        _controller.add( record );
    }

    void dispose( ) {
        _controller.close( );
    }
}
final notification = NotificationCenter._( );


// Usage
// await setupLogger();
// final logger = Logger( 'MyApp' );
// logger.info('System initialized');

// The number of times `getLogger()` is executed depends on **how and where you initialize the `logger` variable**. Here's a breakdown:

// ---

// ### **Scenario 1: Global Variable Initialization**
// If you define `logger` as a **top-level/global variable**:
// ```dart
// // Initialize once when the app starts
// final Logger logger = getLogger();

// void main() {
//   logger.info('App started');
// }
// ```
// - ✅ `getLogger()` is called **once** (at app startup).

// ---

// ### **Scenario 2: Initialized Inside a Class/Function**
// If you reinitialize `logger` every time you use it:
// ```dart
// class MyService {
//   final Logger logger = getLogger(); // Called once per MyService instance
// }

// void myFunction() {
//   final logger = getLogger(); // Called every time myFunction() runs
// }
// ```
// - ❌ `getLogger()` is called **every time** a new instance/function is created.

// ---

// ### **Scenario 3: Singleton Pattern**
// If `getLogger()` internally caches the logger (recommended):
// ```dart
// Logger? _cachedLogger;

// Logger getLogger() {
//   _cachedLogger ??= Logger('MyApp'); // Initialize only once
//   return _cachedLogger!;
// }
// ```
// - ✅ `getLogger()` initializes the logger **once**, even if called multiple times.

// ---

// ### **Key Takeaway**
// - **Without caching**, `getLogger()` runs every time you write `final logger = getLogger()`.
// - **With caching**, it runs **once** (subsequent calls return the cached instance).

// ---

// ### **Best Practice**
// Use a **singleton pattern** to ensure `getLogger()` is called only once:
// ```dart
// // Singleton logger initialization
// Logger getLogger() {
//   return _cachedLogger ??= Logger('MyApp')
//     ..level = Level.ALL
//     ..onRecord.listen((record) => print(record));
// }

// // Usage everywhere
// final logger = getLogger(); // Reuses the cached instance
// ```

// This ensures consistent logging and avoids redundant initialization. 🚀