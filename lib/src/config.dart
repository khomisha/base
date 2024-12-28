
// ignore_for_file: slash_for_doc_comments

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'util.dart';

/**
 * The application start up settings
 */
class Config {    
    static final Config _instance = Config._( );
    static final Map< String, dynamic > config = _instance._config;
    late Map< String, dynamic > _config;
    static final String _fileName = path.join( 'assets', 'cfg', 'app_settings.json' );

    Config._( ) {
        try {
            var file = File( _fileName );
            _config = json.decode( file.readAsStringSync( ) );
        }
        on PathNotFoundException {
            _config = < String, dynamic > { };
            return;
        }
    }
}

void writeConfig( ) {
    try {
        var encoder = const JsonEncoder.withIndent( INDENT );
        var file = File( Config._fileName );
        file.writeAsStringSync( encoder.convert( Config.config ) );
    }
    on PathNotFoundException {
        return;
    }
}

