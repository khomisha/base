// ignore_for_file: slash_for_doc_comments

import 'dart:isolate';
import 'package:easy_isolate/easy_isolate.dart';
import 'logger.dart';
import 'presenter.dart';
import 'util.dart';

/**
 * Broker for sending messages between presenter and model
 */
abstract class Broker implements Presenter {
    // A worker is responsible for a new isolate (thread)
    late Worker _worker;

    Broker( ) {
        _worker = Worker( );
    }

    /**
     * void _isolateHandler( dynamic data, SendPort mainSendPort, SendErrorFunction onSendError ) async
     * top level or static function processes data in isolate
     * data the data to process in isolate and returns to the main thread
     * mainSendPort the main thread port to get data from isolate
     * onSendError the function to handle send error
     */

    @override
    void send( dynamic data ) async {
        if( !_worker.isInitialized ) {
            await _worker.init( 
                _mainHandler, 
                Functions.get( "isolateHandler" ), 
                errorHandler: handleError, 
                queueMode: true 
            );
        }
        _worker.sendMessage( data );
    }

    @override
    void dispose( ) {
        _worker.dispose( );
    }

    void handleError( dynamic data ) {
        if( data is Exception ) {
            logger.severe( data.toString( ), data );
        }
    }

    /**
     * After proccessed data in isolate, receives result and updates (if any) data in main thread
     * 
     * data returned from isolate
     * isolateSendPort the worker (isolate) send port
     */
    void _mainHandler( dynamic data, SendPort isolateSendPort ) {
        update( data );
    }

    @override
    void update( dynamic data );
}
