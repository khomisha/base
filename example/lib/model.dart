
// ignore_for_file: slash_for_doc_comments, constant_identifier_names, avoid_print

import 'package:base/base.dart';
import 'app_constants.dart';

void process( dynamic data ) {
    if( data is Data ) {
        var command = data[ 'command' ] as String;
        try {
            switch( command ) {
                case CREATE:
                    _create( data );
                    break;
                case LOAD:
                    _load( data );
                    break;
                default:
                    data[ 'warning' ] = "No such method $command";
            }
        }
        on Exception catch( e, stack ) {
            data[ 'result' ] = FAILURE;
            data[ ERR_MSG ] = '$command ${ e.toString( ) }';
            data[ ERROR ] = e;
            data[ STACK ] = stack;
        }
    } else {
        throw UnsupportedError( "Data object wrong type $data.runtimeType" );
    }
}

/**
 * Creates empty project data
 * data the [Data] object
 */
void _create( Data data ) {
    sleep( const Duration( seconds: 7 ) );
    data.attributes[ 'data' ] = "created data";
    data.attributes[ 'result' ] = SUCCESS;
}

/**
 * Loads project data from specified file
 * data the [Data] object to load
 */
void _load( Data data ) {
    sleep( const Duration( seconds: 7 ) );
    data.attributes[ 'data' ] = "loaded data";
    data.attributes[ 'result' ] = SUCCESS;
}
