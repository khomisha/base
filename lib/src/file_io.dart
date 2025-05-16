
// ignore_for_file: unused_element, slash_for_doc_comments

import 'dart:convert';
import 'dart:io';
import 'file.dart';
import 'package:path/path.dart';

/**
 * File object desktop implementation
 */
class FileImpl implements GenericFile {
    static String userDir = Platform.environment[ 'HOME' ] ?? Platform.environment[ 'USERPROFILE' ]!;
    static String appDir = Directory.current.path;
    static String assetsDir = _isStandalone( ) ? join( appDir, 'data', 'flutter_assets' ) : appDir;
    late final File _file;

    /**
     * fileName the full file name
     */
    FileImpl( String fileName ) {
        _createDir( fileName ).then( ( value ) => _file = File( fileName ) );
    }

    /**
     *  see [File.readAsString]
     */ 
    @override
    Future< String > readString( ) async {
        return await _file.readAsString( );
    }
    
    /**
     * see [File.writeAsString]
     */
    @override
    void writeString( String contents, { int mode = GenericFile.WRITE } ) async {
        var fileMode = FileMode.write;
        switch( mode ) {
            case GenericFile.WRITE:
                fileMode = FileMode.write;
                break;
            case GenericFile.APPEND:
                fileMode = FileMode.append;
                break;
            case GenericFile.WRITE_ONLY:
                fileMode = FileMode.writeOnly;
                break;
            case GenericFile.WRITE_ONLY_APPEND:
                fileMode = FileMode.writeOnlyAppend;
                break;
        }
        await _file.writeAsString( contents, mode: fileMode, encoding: utf8, flush: false );
    }

    /**
     * Creates directory if it does not exist
     * fileName the full file name
     */
    Future< void > _createDir( String fileName ) async {
        var path = dirname( fileName );
        if( !Directory( path ).existsSync( ) ) {
            await Directory( path ).create( );
        } 
    }
}

/**
 * Returns true if it runs as standalone application, otherwise (ide) false
 */
bool _isStandalone( ) {
    for( var entity in Directory.current.listSync( ) ) {
        if( entity is Directory && entity.path.contains( 'data' ) ) {
            return true;
        }
    }
    return false;
}
