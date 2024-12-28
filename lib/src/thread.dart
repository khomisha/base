// ignore_for_file: slash_for_doc_comments

import 'dart:isolate';
import 'package:easy_isolate/easy_isolate.dart';

abstract class Thread {
    // A worker is responsible for a new isolate (thread)
    late Worker _worker;
    bool init = false;
    late IsolateMessageHandler isolateHandler;

    Thread( this.isolateHandler ) {
        _worker = Worker( );
    }

    /**
     * Sends data to the isolate
     * 
     * arbitrary data object
     */
    void send( dynamic data ) async {
        if( !init ) {
            init = true;
            await _worker.init( _mainHandler, isolateHandler, errorHandler: print, queueMode: true );
        }
        _worker.sendMessage( data );
    }

    /**
     * Closes thread
     */
    void dispose( ) {
        _worker.dispose( );
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

    /**
     * Process data in isolate
     * data the data to process in isolate and returns to the main thread
     * mainSendPort the main thread port to get data from isolate
     * onSendError the function to handle send error
     */
    static _isolateHandler( dynamic data, SendPort mainSendPort, SendErrorFunction onSendError ) async {
        //process( data );
        mainSendPort.send( data );
    }

    /**
     * Updates data in main thread
     */
    void update( dynamic data );
}
