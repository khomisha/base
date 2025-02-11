import 'file_web.dart' if( dart.library.io ) 'file_io.dart';

abstract interface class GenericFile {

    factory GenericFile( String name ) {
        return FileImpl( name );
    }

    String readString( );

    void writeString( String contents );
}