
import 'widget_presenter.dart';

class PresenterRegistry {
    PresenterRegistry._( );
    static final PresenterRegistry _instance = PresenterRegistry._( );

    factory PresenterRegistry( ) {
        return _instance;
    }

    final Map< String, WidgetPresenter > _presenters = { };

    /// Get existing presenter or create and register a new one
    T getPresenter< T extends WidgetPresenter >( String key, T Function( ) create ) {
        final existing = _presenters[ key ];
        if( existing != null ) {
            return existing as T;
        }

        final created = create( );
        _presenters[ key ] = created;
        return created;
    }

    /// Dispose a single presenter
    void disposePresenter( String key ) {
        _presenters.remove( key )?.dispose( );
    }

    /// Dispose all presenters
    void disposeAll( ) {
        for( final p in _presenters.values ) {
            p.dispose( );
        }
        _presenters.clear( );
    }
}
