
/**
 * the stub
 */
extension type JSError( Object _ ) implements Object {
    String get message => throw UnsupportedError( 'Unsupported on non web platforms' );
}

extension StringListInterop on List< String > {
    String get message => throw UnsupportedError( 'Unsupported on non web platforms' );
}

