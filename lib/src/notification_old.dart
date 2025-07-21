
// ignore_for_file: slash_for_doc_comments, avoid_print

/**
 * The notification broker
 */
class Notification {
    static final Notification _instance = Notification._( );
    final _subscribers = < String, List< Subscriber > >{ };
    final messageBoard = < String, dynamic > { };

    Notification._( );

    factory Notification( ) {
        return _instance;
    }

    /**
     * Subscribes specified subscriber to the specified event
     * event the event
     * subscriber the subscriber
     */
    void subscribe( String events, Subscriber subscriber ) {
        var ls = events.split( "," );
        for( String event in ls ) {
            List< Subscriber > list = _subscribers[ event ] ?? < Subscriber > [ ];
            list.add( subscriber );
            _subscribers.putIfAbsent( event, ( ) => list );
        }
    }

    /**
     * Unsubscribes specified subscriber from specified event
     * event the event
     * subscriber the subscriber
     */
    void unsubscribe( String event, Subscriber subscriber ) {
        List< Subscriber >? list = _subscribers[ event ];
        if( list != null ) {
            list.remove( subscriber );
        }
    }

    /**
     * Usubscribes all subscribers
     */
    void unsubscribeAll( ) {
        _subscribers.clear( );
    }

    /**
     * Notifies subscribes that specified event has happened
     * 
     * event the event
     * data the optional data
     */
    void notify( String event ) {
        List< Subscriber >? list = _subscribers[ event ];
        if( list != null ) {
            for( Subscriber s in list ) {
                messageBoard[ event ] == null ? s.receive( event ) : s.receive( event, data: messageBoard[ event ] );
            }
		}			
	} 
}

abstract class Publisher {

    /**
	 * Notifies that specified event has happened
	 * 
	 * event the event
     * data the optional data
	 */
    void publish( String event, { dynamic data } ) {
        if( data != null ) { 
            Notification( ).messageBoard[ event ] = data;
        }
        Notification( ).notify( event );
    }
}

abstract class Subscriber {
    
	/**
	 * Receives that specified event has happened
	 * 
	 * event the event
     * data the optional data
	 */
    void receive( String event, { dynamic data } );
}