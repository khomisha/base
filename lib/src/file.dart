import 'file_web.dart' if( dart.library.io ) 'file_io.dart';

abstract interface class GenericFile {
    static String userDir = FileImpl.userDir;

    factory GenericFile( String name ) {
        return FileImpl( name );
    }

    Future< String > readString( );

    void writeString( String contents );
}