
// ignore_for_file: avoid_print

import 'data.dart';
import 'electron_api.dart';
import 'presenter.dart';
import 'package:js_interop_utils/js_interop_utils.dart';

/**
 * Broker for sending messages between presenter and model
 */
abstract class Broker implements Presenter {

    Broker( );

    @override
    void dispose( ) {
    }

    @override
    void send( Data data ) async {
        await electronAPI.sendMessage( data.attributes.toJSDeep ).toDart.then( 
            ( value ) { 
                var map = < String, dynamic >{ };
                for( var key in value.keys ) {
                    map[ key ] = value.get( key );
                }
                update( Data.fromMap( map ) );
            } 
        );
    }

    @override
    void update( Data data );
}