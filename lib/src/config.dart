
// ignore_for_file: slash_for_doc_comments

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'constants.dart';
import 'file.dart';

/**
 * The application start up settings
 */
class Config {    
    static final Config _instance = Config._( );
    static final Map< String, dynamic > config = _instance._config;
    late Map< String, dynamic > _config;
    static final String _fileName = path.join( 'assets', 'cfg', 'app_settings.json' );

    Config._( ) {
        var file = GenericFile( _fileName );
        file.readString( ).then( ( value ) => _config = json.decode( value ) );
    }
}

void writeConfig( ) {
    var encoder = const JsonEncoder.withIndent( INDENT );
    var file = GenericFile( Config._fileName );
    file.writeString( encoder.convert( Config.config ) );
}

final guiColor = colors[ Config.config[ 'gui_primary_color' ] ] ?? Colors.blue;

