import 'dart:js_interop';

extension type ElectronAPI._( JSObject _ ) implements JSObject {
    external JSPromise< JSString > readFile( JSString path );
    external JSPromise< JSAny > writeFile( JSString path, JSString content );
    external JSString getUserDir( );
}

@JS( )
external ElectronAPI get electronAPI;
