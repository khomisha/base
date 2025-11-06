import 'dart:async';
import 'logger.dart';

//eventBroker.dispatch( event );

abstract class Subscriber {

    /**
     * Subscriber event handler
     * event the event to handle
     */
    void onEvent( Event event );
}

// Event Class
class Event {
    final String _type;
    String get type => _type;

    final dynamic _data;
    dynamic get data => _data;
    final DateTime _timestamp = DateTime.now( );
    DateTime get timestamp => _timestamp;
    final dynamic _source;
    dynamic get source => _source;

    /**
     * type the event type
     * data the optional data object
     * source the optional event source object
     */
    Event( this._type, [ this._data, this._source ] );

    @override
    String toString( ) => '$_timestamp [$_type] ${_data ?? ''} ${_source ?? ''}';
}

/**
 * Event broker dispatches event to interested parties. Eases decoupling by allowing
 * objects to interact without having direct dependencies upon one another, and
 * without requiring event sources to deal with maintaining handler lists. There
 * will typically be one EventBroker per application, broadcasting events that may
 * be of general interest.
 */
class EventBroker {
    final _subscribers = < String, Set< Subscriber > >{ };
    final _eventQueue = StreamController< Event >.broadcast( );

    EventBroker._( ) {
        // Setup async processing
        _eventQueue.stream.listen( _processEvent );
    }

    void subscribe( Subscriber subscriber, String eventType ) {
        _subscribers[ eventType ] ??= < Subscriber >{ };
        _subscribers[ eventType ]!.add( subscriber );
    }

    void unsubscribe( Subscriber subscriber, String eventType ) {
        _subscribers[ eventType ]?.remove( subscriber );
    }

    void dispatch( Event event ) {
        // Add to async queue instead of processing immediately
        _eventQueue.add( event );
    }

    void _processEvent( Event event ) async {
        final subscribers = _subscribers[ event.type ];
        if( subscribers != null ) {
            // Process in parallel using isolates if needed
            await Future.wait( 
                subscribers.map( 
                    ( subscriber ) async {
                        try {
                            logger.info( '$subscriber: ${event.type}' );
                            await _executeSafely( ( ) => subscriber.onEvent( event ) );
                        } 
                        catch( e ) {
                            logger.severe( 'Error in subscriber: $e' );
                        }
                    }
                )
            );
        }
    }

    Future< void > _executeSafely( Function( ) callback ) async {
        try {
            final result = callback( );
            if( result is Future ) await result;
        } 
        catch( e, stack ) {
            logger.severe( 'Event handling error: $e', stack );
        }
    }

    void dispose( ) {
        _subscribers.clear( );
        _eventQueue.close( );
    }
}

final eventBroker = EventBroker._( );


//Concrete Subscriber Implementation ===========================================================

// class UserLoginSubscriber implements Subscriber {

//     @override
//     void onEvent( Event event ) {
//         if( event.type == "userLogin" ) {
//             print( 'Login detected: ${event.data}' );
//             // Heavy processing example
//             _processLoginData( event.data );
//         }
//     }

//     Future< void > _processLoginData( dynamic data ) async {
//         // Simulate heavy computation
//         await Future.delayed( const Duration( milliseconds: 50 ) );
//         print( 'Processed login data' );
//     }
// }

// class AnalyticsSubscriber implements Subscriber {

//     @override
//     void onEvent( Event event ) {
//         switch( event.type ) {
//             case "userLogin":
//                 print( 'Analytics: User login' );
//                 break;
//             case "dataUpdated":
//                 print( 'Analytics: Data update' );
//                 break;
//             case "settingsChanged":
//                 print( 'Settings changed' );
//                 break;
//         }
//     }
// }

// //Usage Example =====================================================
// void main() async {
//     // Create publisher
//     final publisher = EventBroker( );
    
//     // Create subscribers
//     final loginSubscriber = UserLoginSubscriber( );
//     final analyticsSubscriber = AnalyticsSubscriber( );

//     // Subscribe
//     publisher.subscribe( loginSubscriber, "userLogin" );
//     publisher.subscribe( analyticsSubscriber, "userLogin" );
//     publisher.subscribe( analyticsSubscriber, "dataUpdated" );

//     // Publish events (non-blocking)
//     publisher.dispatch( Event( "userLogin", { 'user': 'Alice' } ) );
//     publisher.dispatch( Event( "dataUpdated", [ 1, 2, 3 ] ) );
    
//     print( 'Events published! Main thread continues...' );
    
//     // Wait for async processing to complete
//     await Future.delayed( const Duration( seconds: 1 ) );
    
//     // Cleanup
//     publisher.dispose( );
// }
