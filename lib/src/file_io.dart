
// ignore_for_file: unused_element, slash_for_doc_comments

import 'dart:convert';
import 'dart:io';
import 'file.dart';

class FileImpl implements GenericFile {
    static String userDir = Platform.environment[ 'HOME' ] ?? Platform.environment[ 'USERPROFILE' ]!;
    late final File _file;

    FileImpl( String name ) {
        _file = File( name );
    }

    /**
     *  see [File.readAsString]
     */ 
    @override
    Future< String > readString( ) async {
        return await _file.readAsString();
    }
    
    /**
     * see [File.writeAsStringSync]
     */
    @override
    void writeString( String contents ) {
        _file.writeAsStringSync( contents, mode: FileMode.write, encoding: utf8, flush: false );
    }
}
