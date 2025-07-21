import 'dart:js_interop';
import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'app_electron_api.dart';
import 'app_presenter.dart';

void main( ) async {
    await loadConfig( );
    initLogger( );
    runApp(
        const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MainApp( )
        )
    );
}

class MainApp extends StatefulWidget {
    const MainApp( { super.key } );

    @override
    State< MainApp > createState( ) => _App( );
}

class _App extends State< MainApp > implements Pane {
    late final Supervisor sv;
    bool show = true;

    @override
    void initState( ) {
        logger.info( "initState" );
        sv = Supervisor( this );
        super.initState( );
    }

    @override
    void dispose( ) {
        logger.info( "exiting" );
        super.dispose( );
    }

	@override
	Widget build( BuildContext context ) {
        var title = show ? const Text( "Show" ) : const Text( "Hide" );
		return Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: < Widget >[
                        ElevatedButton(
                            child : const Text( "Load" ),
                            onPressed : ( ) { AppPresenter( ).load( ); }
                        ),
                        ElevatedButton(
                            child : title,
                            onPressed : ( ) { 
                                setState( ( ) => show = !show ); 
                                appElectronAPI.changeVisibility( ).toDart;
                            }
                        ),
                        ElevatedButton(
                            child : const Text( "Error handling" ),
                            onPressed : ( ) async { 
                                try {
                                    var num = 0;
                                    var result = await appElectronAPI.divide( num.toJS ).toDart;
                                    debugPrint( 'result = $result' );
                                }
                                on JSError catch ( e ) {
                                    logger.severe( e.message );
                                }
                            }
                        ),
                        ElevatedButton(
                            onPressed : sv.destroy,
                            child : const Text( "Quit" )
                        ),
                    ]
                )
            ) 
		);
	}
    
    @override
    void onClose( ) {
        dispose( );
    }
}

