
import 'notification.dart';
import 'presenter.dart';

abstract class Broker extends Publisher implements Presenter {
    late dynamic handler;

    Broker( this.handler );

    @override
    void dispose( ) {
    }

    @override
    void send( dynamic data ) {
    }

    @override
    void update( dynamic data );
}