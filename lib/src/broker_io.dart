// ignore_for_file: slash_for_doc_comments

import 'dart:isolate';
import 'package:easy_isolate/easy_isolate.dart';
import 'notification.dart';
import 'presenter.dart';

abstract class Broker extends Publisher implements Presenter {
    // A worker is responsible for a new isolate (thread)
    late Worker _worker;
    bool init = false;
    late IsolateMessageHandler _isolateHandler;

    Broker( dynamic handler ) {
        _isolateHandler = handler;
        _worker = Worker( );
    }

    @override
    void send( dynamic data ) async {
        if( !init ) {
            init = true;
            await _worker.init( _mainHandler, _isolateHandler, errorHandler: print, queueMode: true );
        }
        _worker.sendMessage( data );
    }

    @override
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

    @override
    void update( dynamic data );
}
