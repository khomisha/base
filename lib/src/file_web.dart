// ignore_for_file: unused_element, slash_for_doc_comments

import 'dart:js_interop';
import 'electron_api.dart';
import 'file.dart';
import 'package:path/path.dart' as path;

/**
 * File object web implementation
 */
class FileImpl implements GenericFile {
    final String fileName;
    static String userDir = electronAPI.getUserDir( ).toDart;
    static String appDir = electronAPI.getAppDir( ).toDart;
    static String assetsDir = path.join( appDir, 'assets' );

    /**
     * fileName the full file name
     */
    FileImpl( this.fileName );

    @override
    Future< String > readString( ) async {
        var content = await electronAPI.readFile( fileName.toJS ).toDart.then( ( value ) => value.toDart );
        return content;
    }

    @override
    void writeString( String content, { int mode = 1 } ) async {
        await electronAPI.writeFile( fileName.toJS, content.toJS, mode.toJS ).toDart;
    }
}