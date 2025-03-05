// ignore_for_file: unused_element, slash_for_doc_comments

import 'dart:js_interop';
import 'electron_api.dart';
import 'file.dart';

class FileImpl implements GenericFile {
    final String name;
    static String userDir = electronAPI.getUserDir( ).toDart;

    FileImpl( this.name );

    @override
    Future< String > readString( ) async {
        var content = await electronAPI.readFile( name.toJS ).toDart.then( ( value ) => value.toDart );
        return content;
    }

    @override
    void writeString( String content ) {
        electronAPI.writeFile( name.toJS, content.toJS );
    }
}