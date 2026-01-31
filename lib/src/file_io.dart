
// ignore_for_file: unused_element, slash_for_doc_comments

import 'dart:convert';
import 'dart:io';
import 'file.dart';
import 'package:path/path.dart';
import 'logger.dart';
import 'package:file_picker/file_picker.dart';

/**
 * File object desktop implementation
 */
class FileImpl implements GenericFile {
    static String userDir = Platform.environment[ 'HOME' ] ?? Platform.environment[ 'USERPROFILE' ]!;
    static String appDir = Directory.current.path;
    static String assetsDir = _isStandalone( ) ? 
        join( appDir, 'data', 'flutter_assets', 'assets' ) : 
        join( appDir, 'assets' );
    late final File _file;

    /**
     * fileName the full file name
     */
    FileImpl( String fileName ) {
        mkDir( dirname( fileName ) ).then( ( value ) => _file = File( fileName ) );
    }

    /**
     *  see [File.readAsString]
     */ 
    @override
    Future< String > readString( ) async {
        try {
            return await _file.readAsString( );
        }
        on IOException catch( e, stack ) {
            logger.severe( 'Read file error: $e', stack );
            return "";
        }
    }
    
    /**
     * see [File.writeAsString]
     */
    @override
    void writeString( String contents, { int mode = GenericFile.WRITE } ) async {
        try {
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
        on IOException catch( e, stack ) {
            logger.severe( 'Write file error: $e', stack );
        }
    }

    @override
    void delete( ) {
        _file.delete( );
    }

    /**
     * see [GenericFile.copyDirectory]
     */
    static void copyDirectory( String source, String destination ) {
        var src = Directory( source );
        var dest = Directory( destination );
        if( !dest.existsSync( ) ) {
            dest.createSync( recursive: true );
        }

        src.listSync( recursive: false ).forEach( 
            ( var entity ) {
                if( entity is Directory ) {
                    var newDirectory = join( dest.absolute.path, basename( entity.path ) );
                    copyDirectory( entity.absolute.path, newDirectory );
                } else if( entity is File ) {
                    entity.copySync( join( dest.path, basename( entity.path ) ) );
                }
            }
        );
    }
    
    /**
     * see [GenericFile.mkDir]
     */
    static Future< void > mkDir( String path ) async {
        if( !Directory( path ).existsSync( ) ) {
            await Directory( path ).create( );
        } 
    }

    /**
     * see [GenericFile.isExist]
     */
    static bool isExist( String path ) {
        return Directory( path ).existsSync( );
    }
    /**
     * Returns true if it runs as standalone application, otherwise (ide) false
     */
    static bool _isStandalone( ) {
        for( var entity in Directory.current.listSync( ) ) {
            if( entity is Directory && entity.path.contains( 'data' ) ) {
                return true;
            }
        }
        return false;
    }

    /**
     * see [GenericFile.pickFile]
     */
    static Future< String? > pickFile( { title, filterName, extensions } ) async {
        FilePickerResult? result = await FilePicker.platform.pickFiles( 
            dialogTitle: title,
            allowedExtensions: extensions 
        );
        if( result != null ) {
            return result.files.single.path as String;
        } else {
            return null;
        }
    } 
}

