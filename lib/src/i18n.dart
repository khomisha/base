
// ignore_for_file: slash_for_doc_comments

import 'dart:convert';
import 'package:path/path.dart' as path;
import 'file.dart';
import 'logger.dart';

/**
 * Lightweight GUI localization.
 *
 * The language is chosen once at start up from the `language` setting in
 * app_settings.json (e.g. "en_US", "ru_RU"). Translations live in
 * assets/l10n/<code>.json so the wording can be edited without touching Dart.
 * Every user facing string is looked up with [tr] by a stable key; missing
 * translations fall back to English and then to the key itself, so the UI
 * never shows a blank label.
 */

const String _defaultLang = 'en';

String _lang = _defaultLang;
Map< String, String > _strings = < String, String > { };
Map< String, String > _fallback = < String, String > { };

/**
 * Loads the translation table for [code] from assets/l10n/<code>.json,
 * returning an empty map when the file is absent or invalid.
 */
Future< Map< String, String > > _load( String code ) async {
    try {
        final file = GenericFile( path.join( GenericFile.assetsDir, 'l10n', '$code.json' ) );
        final raw = await file.readString( );
        final map = json.decode( raw ) as Map< String, dynamic >;
        return map.map( ( key, value ) => MapEntry( key, value.toString( ) ) );
    } catch( e ) {
        logger.warning( "Cannot load translations for '$code': $e" );
        return < String, String > { };
    }
}

/**
 * Resolves and loads the active language from a locale string such as
 * "ru_RU" or "en". English is always loaded as the fallback table, and an
 * unsupported language falls back to English entirely. Call once after the
 * config is loaded and before any [tr] lookup.
 */
Future< void > initI18n( String? locale ) async {
    final code = ( locale ?? _defaultLang ).split( RegExp( r'[_\-]' ) ).first.toLowerCase( );
    _fallback = await _load( _defaultLang );
    _strings = code == _defaultLang ? _fallback : await _load( code );
    _lang = _strings.isEmpty ? _defaultLang : code;
    logger.info( "GUI language: $_lang" );
}

/**
 * The active two letter language code, e.g. 'en' or 'ru'.
 */
String get languageCode => _lang;

/**
 * Translates [key] into the active language, falling back to English and
 * then to the key itself when a translation is missing.
 */
String tr( String key ) {
    return _strings[ key ] ?? _fallback[ key ] ?? key;
}
