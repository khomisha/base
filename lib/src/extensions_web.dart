import 'package:js_interop_utils/js_interop_utils.dart';

/**
 * see [example]
 */
@staticInterop
extension type JSError( JSObject _ ) implements JSObject {
    external String get message;
}

extension StringListInterop on List< String > {
    JSArray< JSString > toJSArray( ) {
        final jsArray = JSArray< JSString >( );
        for( final item in this ) {
            jsArray.push( item.toJS );
        }
        return jsArray;
    }
}

extension JSArrayInterop on JSArray< JSString > {
    List<String> toDartStringList( ) {
        final list = < String >[ ];
        for( var i = 0; i < length; i++ ) {
            list.add( this[ i ].toDart );
        }
        return list;
    }
}