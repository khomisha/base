
// ignore_for_file: slash_for_doc_comments

import 'package:flutter/material.dart';
import 'notification.dart';
import 'util.dart';

abstract class WidgetPresenter extends ChangeNotifier implements Subscriber {
    final String dataType;
    late int editIndex;
    late List< ListItem > _list;
    List< ListItem > get list => _list;
    int selectedIndex = -1;
    set list( List< ListItem > value ) {
        _list = value;
        _list.sort( );
        // Adjust selectedIndex only if it was previously set to a valid index that is now out of bounds
        if( selectedIndex != -1 && selectedIndex >= _list.length ) {
            selectedIndex = _list.isEmpty ? -1 : 0;
        }
        // Set the state of the selected item (if any)
        if( selectedIndex != -1 && selectedIndex < _list.length ) {
            _list[ selectedIndex ].setState( ListItemState.selected.index );
        }
        notifyListeners( );
    }    
    bool readOnly = true;
    bool adding = false;

    WidgetPresenter( this.dataType );

    /**
     * Adds empty data
     */
    int add( ) {
        return 0;
    }

    /**
     * Deletes specified data
     * index the item data index
     */
    void delete(int index) {
        // Remove the item
        _list.removeAt( index );
        // Adjust selectedIndex based on what was removed
        if( selectedIndex == index ) {
            // The selected item itself was deleted
            if( _list.isEmpty ) {
                selectedIndex = -1;
            } else {
                // Select the item that now occupies the same index (or the last one)
                selectedIndex = index < _list.length ? index : _list.length - 1;
            }
        } else if( selectedIndex > index ) {
            // An item before the selected one was deleted -> shift left
            selectedIndex--;
        }
        // Ensure selectedIndex is within bounds (already done)
        onSuccess( );
    }

    /**
     * Starts editing specified data
     * index the item data index
     */
    void startEdit( int index ) {
        editIndex = index;
        readOnly = false;
    }

    /**
     * Ends editing data
     * ok the end editing success flag
     */
    void endEdit( bool ok ) {
        if( ok ) {
            onSuccess( );
        } else {
            if( !adding ) {
                notifyListeners( );
            }
        }
        adding = false;
    }

    /**
     * Updates specified attribute
     * attributeName the attribute name
     * newValue the new value
     * notify the notify flag
     */
    void update( String attributeName, dynamic newValue, bool notify ) {
        var value = list[ editIndex ].customData[ attributeName ];
        if( value is List ) {
            var length = value.length;
            // if try to add item which already in list, remove it
            value.removeWhere( 
                ( e ) => e.customData.attributes[ 'name' ] == newValue.customData.attributes[ 'name' ] 
            );
            if( value.length == length ) {
                // on previous step there is no item to remove, therefore new item will be add 
                value.add( newValue );
            }
            value.sort( );
        } else {
            list[ editIndex ].customData[ attributeName ] = newValue;
            onUpdate( attributeName, newValue );
        }
        if( notify ) {
            notifyListeners( );
        }
    } 

    /**
     * On update list item some actions in desendent
     */
    void onUpdate( String attributeName, dynamic newValue ) {
    }

    @override
    void onEvent( Event event );

    /**
     * Selects specified item
     * index the item index to select
     */
    void select( int index ) {
    }

    /** 
     * Returns specified data
     * index the data index
     */
    ListItem get( int index ) {
        return _list[ index ];
    }

    /**
     * On success operation desendent action
     */
    void onSuccess( ) {
    }

    /**
     * On set list some actions in desendent
     */
    void onSet( ) {
    }
}