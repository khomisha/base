
import 'dart:js_interop';
import 'pane.dart';
import 'package:web/web.dart' as web;

class Supervisor {
    final Pane pane;

    Supervisor( this.pane ) {
        web.window.addEventListener(
            'beforeunload', 
            _handleBeforeUnload.toJS        
        );
    }

    void destroy( ) {
        web.window.close( );
    }

    web.EventListener? _handleBeforeUnload( web.Event event ) {
        pane.onClose( );
        return null;
    }
}