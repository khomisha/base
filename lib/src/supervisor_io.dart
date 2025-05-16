import 'package:window_manager/window_manager.dart';
import 'pane.dart';

class Supervisor with WindowListener {
    final Pane pane;

    Supervisor( this.pane ) {
        windowManager.addListener( this );
    }

    void destroy( ) {
        windowManager.destroy( );
    }

    @override
    void onWindowClose( ) {
        pane.onClose( );
        windowManager.removeListener( this );
    }    
}