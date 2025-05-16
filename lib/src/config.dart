
// ignore_for_file: slash_for_doc_comments

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'constants.dart';
import 'file.dart';

/**
 * The application start up settings
 */

final file = GenericFile( path.join( GenericFile.assetsDir, 'assets', 'cfg', 'app_settings.json' ) );
late final Map< String, dynamic > config;

/**
 * Updates application config
 */
void updateConfig( ) {
    var encoder = const JsonEncoder.withIndent( INDENT );
    file.writeString( encoder.convert( config ) );
}

/**
 * Loads application config
 */
Future< void > loadConfig( ) async {
    var value = await file.readString( );
    config = json.decode( value ) as Map< String, dynamic >;
}

final guiColor = colors[ config[ 'gui_primary_color' ] ] ?? Colors.blue;
