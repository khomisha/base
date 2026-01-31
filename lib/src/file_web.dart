// ignore_for_file: unused_element, slash_for_doc_comments

import 'electron_api.dart';
import 'file.dart';
import 'package:path/path.dart' as path;
import 'extensions_web.dart';
import 'logger.dart';
import 'package:js_interop_utils/js_interop_utils.dart';

/**
 * File object web implementation
 */
class FileImpl implements GenericFile {
    final String fileName;
    static String userDir = electronAPI.getUserDir( ).toDart;
    static String appDir = electronAPI.getAppDir( ).toDart;
    static String assetsDir = path.join( appDir, 'assets', 'assets' );

    /**
     * fileName the full file name
     */
    FileImpl( this.fileName );

    @override
    Future< String > readString( ) async {
        try {
            var content = await electronAPI.readFile( fileName.toJS ).toDart.then( ( value ) => value.toDart );
            return content;
        }
        on JSError catch ( e ) {
            logger.severe( e.message );
            return "";
        }
    }

    @override
    void writeString( String content, { int mode = 1 } ) async {
        try {
            await electronAPI.writeFile( fileName.toJS, content.toJS, mode.toJS ).toDart;
        }
        on JSError catch ( e ) {
            logger.severe( e.message );
        }
    }

    @override
    void delete( ) {
        electronAPI.delete( fileName.toJS ).toDart;
    }
    
    /**
     * see [GenericFile.copyDirectory]
     */
    static void copyDirectory( String source, String destination ) async {
        try {
            await electronAPI.copyDir( source.toJS, destination.toJS ).toDart;
        }
        on JSError catch ( e ) {
            logger.severe( '${e.message} source $source destination $destination' );
        }
    }

    /**
     * see [GenericFile.mkDir]
     */
    static void mkDir( String path ) {
        electronAPI.mkDir( path.toJS ).toDart;
    }

    /**
     * see [GenericFile.isExist]
     */
    static bool isExist( String path ) {
        return electronAPI.isExist( path.toJS ).toDart;
    }

    /**
     * see [GenericFile.pickFile]
     */
    static Future< String? > pickFile( String title, String filterName, List< String > extensions ) async {
        final options = {
            'title': title,
            'filters': [ { 'name': filterName, 'extensions': extensions } ],
            'properties': [ 'openFile' ]
        };

        final JSString? jsResult = await electronAPI.pickupFile( options.toJSDeep ).toDart;

        return jsResult?.toDart;
    }
} 