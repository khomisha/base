
// ignore_for_file: slash_for_doc_comments, constant_identifier_names

import 'package:base/base.dart';

abstract class Presenter extends Thread {
    final _subscribers = < String, WidgetPresenter > { };

    Presenter( super.isolateHandler );

    /**
     * Closes presenter
     */
    @override
    void dispose( ) {
        super.dispose( );
        for( WidgetPresenter wp in _subscribers.values ) {
            wp.dispose( );
        }
    }

    /**
     * Subscribes specified presenter
     * widgetPresenter the presenter to subscribe
     */
    void subscribe( WidgetPresenter widgetPresenter ) {
        _subscribers[ widgetPresenter.dataType ] = widgetPresenter;
        widgetPresenter.list = getData( widgetPresenter.dataType );
    }

    /**
     * Unsubscribes specified presenter
     * type the application data type
     */
    void unsubscribe( String type ) {
        _subscribers.remove( type );
    }

    /**
     * Usubscribes all subscribers
     */
    void unsubscribeAll( ) {
        for( String type in _subscribers.keys ) {
            _subscribers.remove( type );
        }
    }
    
    /**
     * Returns specified application data
     * type the application data type
     */
    List< ListItem > getData( String type );

    /**
     * Notifies subscribers that the application data is changed
     */
    void notify( ) {
        for( String type in _subscribers.keys ) {
            var wp = _subscribers[ type ] as WidgetPresenter;
            wp.list = getData( type );
        }
    }

    /**
     * Returns specified presenter
     * type the presenter type
     */
    WidgetPresenter getPresenter( String type ) {
        return _subscribers[ type ]!;
    }
}
