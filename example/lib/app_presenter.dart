
// ignore_for_file: constant_identifier_names, slash_for_doc_comments, avoid_print

import 'app_constants.dart';
import 'package:base/base.dart';
import 'broker_init_web.dart' if (dart.library.io) 'broker_init_io.dart';

class AppPresenter extends Publisher {
    static final AppPresenter _instance = AppPresenter._( );
    late AppBroker _broker;

    AppPresenter._( ) {
        _broker = AppBroker( );
    }

    factory AppPresenter( ) {
        return _instance;
    }

    void create( ) {
        _broker.send(
            Data.create( 
                < String > [ 'command', 'data', 'result' ], 
                < dynamic > [ CREATE, "", NO_ACTION ] 
            )
        );
    }

    void load( ) {
        _broker.send(
            Data.create( 
                < String > [ 'command', 'data', 'result' ], 
                < dynamic > [ LOAD, "", NO_ACTION ] 
            )
        );
    }

    void dispose( ) {
        _broker.dispose( );
    }
}

class AppBroker extends Broker with Initing {

    AppBroker( ) {
        init( );
    }

    @override
    void update( data ) {
        if( data[ 'result' ] == SUCCESS ) {
            if( data[ 'command' ] == CREATE || data[ 'command' ] == LOAD ) {
                logger.info( data[ 'data' ] );
            }
        } else if( data[ 'result' ] == FAILURE ) {
            logger.severe( data[ ERR_MSG ], data[ ERROR ], data[ STACK ] );
        }
    }
}


