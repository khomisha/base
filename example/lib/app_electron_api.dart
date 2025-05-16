import 'dart:js_interop';

/**
 * see [flutter2electron_bridge.md]
 */
extension type AppElectronAPI._( JSObject _ ) implements JSObject {
    external JSPromise< JSAny > changeVisibility( );
    external JSPromise< JSAny > divide( JSNumber num );
}

@JS( )
external AppElectronAPI get appElectronAPI;

@staticInterop
extension type JSError( JSObject _ ) implements JSObject {
    external String get message;
}
