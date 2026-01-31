import 'dart:js_interop';

/**
 * see [flutter2electron_bridge.md]
 */
extension type ElectronAPI._( JSObject _ ) implements JSObject {
    external JSPromise< JSString > readFile( JSString path );
    external JSPromise< JSAny > writeFile( JSString path, JSString content, JSNumber mode );
    external JSString getUserDir( );
    external JSString getAppDir( );
    external JSBoolean isExist( JSString path );
    external JSPromise< JSObject > sendMessage( JSObject? data );
    external JSPromise< JSAny > changeVisibility( );
    external JSPromise< JSAny > copyDir( JSString src, JSString dest );
    external JSPromise< JSAny > mkDir( JSString path );
    external JSPromise< JSAny > delete( JSString path );
    external JSPromise< JSString? > pickupFile( JSAny options );
}

@JS( )
external ElectronAPI get electronAPI;

