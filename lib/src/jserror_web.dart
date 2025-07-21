import 'dart:js_interop';

/**
 * see [example]
 */
@staticInterop
extension type JSError( JSObject _ ) implements JSObject {
    external String get message;
}
