import 'dart:js_interop';

/**
 * see [flutter2electron_bridge.md]
 */
extension type ElectronAPI._( JSObject _ ) implements JSObject {
    external JSPromise< JSString > readFile( JSString path );
    external JSPromise< JSAny > writeFile( JSString path, JSString content, JSNumber mode );
    external JSString getUserDir( );
    external JSString getAppDir( );
    external JSPromise< JSObject > sendMessage( JSObject? data );
}

@JS( )
external ElectronAPI get electronAPI;

/**
 * see [example]
 */
@staticInterop
extension type JSError( JSObject _ ) implements JSObject {
    external String get message;
}
