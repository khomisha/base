
// ignore_for_file: slash_for_doc_comments

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'constants.dart';
import 'file.dart';

/**
 * The application start up settings
 */

final _file = GenericFile( path.join( GenericFile.assetsDir, 'cfg', 'app_settings.json' ) );
late final Map< String, dynamic > config;

/**
 * Updates application config
 */
void updateConfig( ) {
    var encoder = const JsonEncoder.withIndent( INDENT );
    _file.writeString( encoder.convert( config ) );
}

late final Color guiColor;

/**
 * Loads application config
 */
Future< void > loadConfig( ) async {
    var value = await _file.readString( );
    config = json.decode( value ) as Map< String, dynamic >;
    guiColor = colors[ config[ 'gui_primary_color' ] ] ?? Colors.blue;
}
