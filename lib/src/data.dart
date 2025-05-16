
// ignore_for_file: slash_for_doc_comments

import 'attribute_map.dart';

/**
 * Generic object to transfer data between presenter and model
 */
class Data extends AttributeMap< String, dynamic > {

    Data( );

    Data.fromMap( Map< String, dynamic > map ) {
        attributes = map;
    }

    @override
    int compareTo( other ) {
        if( other is! Data ) {
            return 1;
        }
        if( attributes.keys.length > other.attributes.keys.length ) {
            return 1;
        }
        if( attributes.keys.length < other.attributes.keys.length ) {
            return -1;
        }
        for( String key in attributes.keys ) {
            if( !other.attributes.containsKey( key ) ) {
                return 1;
            }
            var result = attributes[ key ].compareTo( other.attributes[ key ] );
            if( result != 0 ) {
                return result;
            }
        }
        return 0;
    }

    @override
    Data copy( ) {
        var duplicate = Data( );
        duplicate.attributes.addAll( attributes );
        return duplicate;
    }

    /**
     * Creates data object with specified keys and values
     * keys the keys
     * values the relevant values
     */
    static Data create( List< String > keys, List< dynamic > values ) {
        var data = Data( );
        int index = 0;
        for( String key in keys ) {
            data.attributes[ key ] = values[ index ];
            index++; 
        }
        return data;
    }

    @override
    String toString( ) {
        return '${attributes.keys.toList( )} ${attributes.values.toList( )}';
    }
}
