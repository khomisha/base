
// ignore_for_file: slash_for_doc_comments

/**
 * Arbitrary attribute map
 */
abstract class AttributeMap< K, V > implements Comparable {
    late Map< K, V > _attributes;
     
    AttributeMap( ) {
       _attributes = < K, V > { }; 
    }

    V? operator []( K key ) {
        if( _attributes.containsKey( key ) ) {
            return _attributes[ key ];
        } else {
            throw UnsupportedError( "No attribute named $key" );
        }
    }
    operator []=( K key, V value ) { _attributes[ key ] = value; }
    Map< K, V > get attributes => _attributes;
    set attributes( Map< K, V > value ) => this._attributes = value;

    dynamic copy( );

    @override
    String toString( ) {
        return _attributes.toString( );
    }
}

