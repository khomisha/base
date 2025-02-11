// ignore_for_file: unused_element, slash_for_doc_comments

import 'file.dart';

class FileImpl implements GenericFile {
    static String userDir = "web";
    final String name;

    FileImpl( this.name );

    @override
    String readString( ) {
        return "";
    }

    @override
    void writeString( String contents ) {
    }
}