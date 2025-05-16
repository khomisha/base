Here's an flutter bridge to the electron:

```javascript
// 1. main.js (Electron main process)
// Modules to control application life and create native browser window
// main.js

// Modules to control application life and create native browser window
const { app, BrowserWindow, ipcMain } = require( 'electron' )
const path = require( 'node:path' )
const fs = require( 'fs/promises' );
const fsSync = require( 'fs' );

// Constants
const CREATE = 'create';
const LOAD = 'load';
const SUCCESS = 0;
const FAILURE = 1;
const ERR_MSG = 'error_message';
const ERROR = 'error';
const STACK = 'stack_trace';
const READ = 0;
const WRITE = 1;
const APPEND = 2;
const WRITE_ONLY = 3;
const WRITE_ONLY_APPEND = 4;

let browser = null;

const createWindow = ( ) => {
    // Create the main window.
    const mainWindow = new BrowserWindow( 
        {
            width: 800,
            height: 600,
            webPreferences: { 
                nodeIntegration: true, 
                contextIsolation: true,
                preload: path.join( __dirname, 'preload.js' ) 
            }
        }
    )

    // Create the secondary window
    const browser = new BrowserWindow(
        {
            width: 800,
            height: 600,
            x: 100,
            y: 100,
            show: false,
            closable: false,
            webPreferences: { 
                nodeIntegration: true, 
                contextIsolation: true
            }
        }
    )

    mainWindow.setMenuBarVisibility( false );
    browser.setMenuBarVisibility( false );
    
    mainWindow.on( "closed", 
        ( ) => {
            browser.close( );
        }
    );

    // and load the index.html of the app.
    mainWindow.loadFile( 'index.html' );

    // Open the DevTools.
    mainWindow.webContents.openDevTools( );

    browser.loadURL( 'http://anserteko.ru' );
}

ipcMain.handle( 
	'read-file', 
	async ( _, fileName ) => {
		try {
			return await fs.readFile( fileName, 'utf-8' );
		} catch( err ) {
            throw new Error( `File read failed: ${err.message}\n${err.stack}` );
		}
	}
);

ipcMain.handle( 
	'process', 
	async ( _, data ) => {
		try {
            return await process( data );   
		} catch( err ) {
            throw new Error( `Process data failed: ${err.message}\n${err.stack}` );
		}
	}
);

ipcMain.handle( 
	'divide', 
	async ( _, num ) => {
        try {
            return divide( num );
        }
        catch( err ) {
            throw new Error( `${err.message}\n${err.stack}` );
        }
	}
);

ipcMain.on( 
    'user-dir', 
    ( event, arg ) => {
        event.returnValue = app.getPath( 'home' );
    }
);

ipcMain.on( 
    'app-dir', 
    ( event, arg ) => {
        event.returnValue = app.getAppPath( );
    }
);

ipcMain.on( 
    'exists', 
    ( event, path ) => {
        event.returnValue = fs.existsSync( path );
    }
);

ipcMain.handle( 
    'change-visibility', 
    async ( _, arg ) => {
		try {
            var visible = browser.isVisible( )
            if( visible ) {
			    browser.hide( );
            } else {
                browser.show( );
            }
            return visible
		} catch( err ) {
            throw new Error( `Change visibility failed: ${err.message}\n${err.stack}` );
		}
    }
);

ipcMain.handle( 
    'write-file', 
    async ( _, fileName, content, mode ) => {
		try {
            await fs.mkdir( path.dirname( fileName ), { recursive: true } );
            if( mode == WRITE ) {
                fs.writeFile( fileName, content, 'utf-8' );
            }
            if( mode == APPEND ) {
                 fs.appendFile( fileName, content, 'utf-8' );
            }
            return "success"
		} catch( err ) {
            throw new Error( `File write failed: ${err.message}\n${err.stack}` );
		}
    }
);

async function process( data ) {
    var map = new Map( Object.entries( data ) );
    const command = map.get( 'command' );
    try {
        switch( command ) {
            case CREATE:
                await _create( map );
                break;
            case LOAD:
                await _load( map );
                break;
            default:
                map.set( 'warning', `No such method ${command}` );
        }
    } catch( e ) {
        // Error handling
        map.set( 'result', FAILURE );
        map.set( ERR_MSG, `${command} ${e.message}` );
        map.set( ERROR, e );
        map.set( STACK, e.STACK );
    }
    return Object.fromEntries( map.entries( ) );
};

// Async sleep helper
function sleep( ms ) {
    return new Promise( resolve => setTimeout( resolve, ms ) );
}

// Processing functions
async function _create( map ) {
    await sleep( 7000 );
    map.set( 'data', "created data" );
    map.set( 'result', SUCCESS );
}

async function _load( map ) {
    await sleep( 7000 );
    map.set( 'data', "loaded data" );
    map.set( 'result', SUCCESS );
}

function divide( num ) {             
    if( num < 1 ) {
        throw new Error( 'Division by 0' );
    }
    return 8 / num;
}
  
// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.whenReady( ).then( 
    ( ) => {
        createWindow( )

        app.on( 
            'activate', 
            ( ) => {
                // On macOS it's common to re-create a window in the app when the
                // dock icon is clicked and there are no other windows open.
                if( BrowserWindow.getAllWindows( ).length === 0 ) createWindow( )
            }
        )
    }
)

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on( 'window-all-closed', ( ) => { if( process.platform !== 'darwin' ) app.quit( ) } )

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.
```

```javascript
// 2. preload.js
const { contextBridge, ipcRenderer } = require( 'electron' );

contextBridge.exposeInMainWorld(
	'electronAPI', 
	{
		readFile: ( path ) => ipcRenderer.invoke( 'read-file', path ),
		writeFile: ( path, content, mode ) => ipcRenderer.invoke( 'write-file', path, content, mode ),
		getUserDir: ( ) => ipcRenderer.sendSync( 'user-dir' ),
		getAppDir: ( ) => ipcRenderer.sendSync( 'app-dir' ),
		isExist: ( ) => ipcRenderer.sendSync( 'exists', path ),
		sendMessage: ( data ) => ipcRenderer.invoke( 'process', data ),
	}
);

contextBridge.exposeInMainWorld(
	'appElectronAPI', 
	{
		changeVisibility: ( ) => ipcRenderer.invoke( 'change-visibility' ),
		divide: ( num ) => ipcRenderer.invoke( 'divide', num )
	}
);
```

```html
<!-- 3. index.html -->
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta content="IE=Edge" http-equiv="X-UA-Compatible" />
    <meta name="description" content="A new Flutter project." />

    <!-- Favicon -->
    <link rel="shortcut icon" type="image/png" href="favicon.png" />

    <title>ElF</title>
    <link rel="manifest" href="manifest.json" />
  </head>
  <body>
    <script src="main.dart.js" type="application/javascript"></script>
  </body>
</html>
```

```dart
// 4. lib/main.dart
import 'dart:js_interop';
import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'app_electron_api.dart';
import 'app_presenter.dart';

void main( ) async {
    await loadConfig( );
    setupLogger( );
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
```

```dart
// 5. base/lib/src/electron_api.dart
// Define JS interop types
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
```

```dart
// 6. lib/app_electron_api.dart
// Define JS interop types
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
```

```dart
// 6. base/lib/src/file.dart
// Conditional import
import 'file_web.dart' if( dart.library.io ) 'file_io.dart';

/**
 * File wrapper
 */
abstract interface class GenericFile {
    static const int READ = 0;
    static const int WRITE = 1;
    static const int APPEND = 2;

    // Mode for opening a file for writing *only*. The file is
    // overwritten if it already exists. The file is created if it does not
    // already exist.
    static const int WRITE_ONLY = 3;

    /// Mode for opening a file for writing *only* to the
    /// end of it. The file is created if it does not already exist.
    static const WRITE_ONLY_APPEND = 4;

    static String userDir = FileImpl.userDir;
    static String appDir = FileImpl.appDir;
    static String assetsDir = FileImpl.assetsDir;

    /**
     * fileName the full file name
     */
    factory GenericFile( String fileName ) {
        return FileImpl( fileName );
    }

    /**
     * Reads file as string
     */
    Future< String > readString( );

    /**
     * Writes string to the file, existing file content will be rewritten
     * content the content to write
     * mode the write mode, default [WRITE]
     */
    void writeString( String content, { int mode } );
}
```

```dart
// 7. lib/app_presenter.dart
// Conditional import

// ignore_for_file: constant_identifier_names, slash_for_doc_comments, avoid_print

import 'app_constants.dart';
import 'package:base/base.dart';
import 'broker_init_web.dart' if (dart.library.io) 'broker_init_io.dart';

class AppPresenter extends Publisher {
    static final AppPresenter _instance = AppPresenter._( );
    late AppBroker _broker;

    AppPresenter._( ) {
        _broker = AppBroker( );
    }

    factory AppPresenter( ) {
        return _instance;
    }

    void create( ) {
        _broker.send(
            Data.create( 
                < String > [ 'command', 'data', 'result' ], 
                < dynamic > [ CREATE, "", NO_ACTION ] 
            )
        );
    }

    void load( ) {
        _broker.send(
            Data.create( 
                < String > [ 'command', 'data', 'result' ], 
                < dynamic > [ LOAD, "", NO_ACTION ] 
            )
        );
    }

    void dispose( ) {
        _broker.dispose( );
    }
}

class AppBroker extends Broker with Initing {

    AppBroker( ) {
        init( );
    }

    @override
    void update( data ) {
        if( data[ 'result' ] == SUCCESS ) {
            if( data[ 'command' ] == CREATE || data[ 'command' ] == LOAD ) {
                logger.info( data[ 'data' ] );
            }
        } else if( data[ 'result' ] == FAILURE ) {
            logger.severe( data[ ERR_MSG ], data[ ERROR ], data[ STACK ] );
        }
    }
}
```

**Flutter Project Structure:**
```
example/
└── assets/cfg
            └── app_settings.json
└── lib/
    ├── main.dart
	├── broker_init_io.dart
	├── broker_init_web.dart
    ├── app_electron_api.dart
    ├── app_constants.dart
    ├── model.dart
	└── app_presenter.dart
└── web/
	├── package.json
	├── main.js
	├── preload.js
	├── index.html
	└── manifest.json
├── pubspec.yaml
```

**pubspec.yaml updates:**
```yaml
name: testiso
description: "A new Flutter project."
publish_to: 'none'
version: 0.1.0

environment:
  sdk: '>=3.4.1 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  base:
    path: ../
  easy_isolate: ^1.3.1
  path: ^1.9.0
  error_trace: ^1.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/cfg/
```

**package.json**
```json
{
    "name": "testiso",
    "version": "1.0.0",
    "description": "TestIso",
    "main": "main.js",
    "scripts": {
        "start": "electron ."
    },
    "author": "MKH",
    "license": "Apache-2.0",
    "devDependencies": {
        "electron": "^33.2.1"
    }
}
```

**manifest.json**
```json
{
    "name": "testiso",
    "short_name": "testiso",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#0175C2",
    "theme_color": "#0175C2",
    "description": "A new Flutter project.",
    "orientation": "portrait-primary",
    "prefer_related_applications": false,
    "icons": [
        {
            "src": "icons/Icon-192.png",
            "sizes": "192x192",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-512.png",
            "sizes": "512x512",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-maskable-192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "maskable"
        },
        {
            "src": "icons/Icon-maskable-512.png",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "maskable"
        }
    ]
}
```

**To Build:**
```bash
flutter build web --no-web-resources-cdn
```

**To Run:**
```bash
cd ./build/web/
npm start
```
