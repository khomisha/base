Here's an flutter bridge to the electron:

```javascript
// 1. main.js (Electron main process)
// Modules to control application life and create native browser window
const { app, BrowserWindow, ipcMain } = require( 'electron' )
const path = require( 'node:path' )
const fs = require('fs/promises');

const createWindow = ( ) => {
    // Create the browser window.
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

    mainWindow.setMenuBarVisibility( false );
    
    // and load the index.html of the app.
    mainWindow.loadFile( 'index.html' )

    // Open the DevTools.
    mainWindow.webContents.openDevTools( )
}

ipcMain.handle( 
	'read-file', 
	async ( _, path ) => {
		try {
			return await fs.readFile( path, 'utf-8' );
		} catch( error ) {
			throw new Error( `File read failed: ${error.message}` );
		}
	}
);

ipcMain.handle( 
    'write-file', 
    async ( _, path, content ) => {
		try {
			fs.writeFile( path, content, 'utf-8' );
		} catch( error ) {
			throw new Error( `File write failed: ${error.message}` );
		}
    }
);

ipcMain.on( 
    'user-dir', 
    ( event, arg ) => {
        event.returnValue = app.getPath( 'home' );
    }
);


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
		writeFile: ( path, content ) => ipcRenderer.invoke( 'write-file', path, content )
        getUserDir: ( ) => ipcRenderer.sendSync( 'user-dir' )
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
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'file.dart';

void main( ) => runApp( 
    MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData( primarySwatch: Colors.blue ),
        home: const MyApp( )
    )
);

class MyApp extends StatefulWidget {
    const MyApp( { super.key } );

    @override
    State< MyApp > createState( ) => _App( );
}

class _App extends State< MyApp > {
    String text = 'Hello, World!';
    final file = GenericFile( path.join( ".", 'assets', 'text.txt' ) );

    void loadText ( ) {
        file.readString( ).then( ( value ) { setState( ( ) => text = value ); } );
    }

    void save( String content ) {
        file.writeString( content );
    }

    @override
    Widget build( BuildContext context ) {
        var textField = TextFormField( 
            controller: TextEditingController( text: text.toString( ) ),
            maxLines: null
        );
        return Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: < Widget >[
                        Text( GenericFile.userDir, style: TextStyle( fontSize: 12 ) ),
                        textField,
                        ElevatedButton(
                            child: const Text( "Load" ),
                            onPressed: loadText
                        ),
                        ElevatedButton(
                            child : const Text( "Save" ),
                            onPressed : ( ) { save( textField.controller!.text ); }
                        )
                    ]
                )
            ) 
        );
    }
}
```

```dart
// 5. lib/file_web.dart
// Define JS interop types
extension type ElectronAPI._( JSObject _ ) implements JSObject {
    external JSPromise< JSString > readFile( JSString path );
    external JSPromise< JSAny > writeFile( JSString path, JSString content );
    external JSString getUserDir( );
}

@JS( )
external ElectronAPI get electronAPI;

class FileImpl implements GenericFile {
    final String name;
    static String userDir = electronAPI.getUserDir( ).toDart;

    FileImpl( this.name );

    @override
    Future< String > readString( ) async {
		// Explicit type conversion using toJS/toDart
        var content = await electronAPI.readFile( name.toJS ).toDart.then( ( value ) => value.toDart );
        return content;
    }

    @override
    void writeString( String content ) {
        electronAPI.writeFile( name.toJS, content.toJS );
    }
}
```

```dart
// 5. lib/file.dart
// Conditional import
import 'file_web.dart' if( dart.library.io ) 'file_io.dart';

abstract interface class GenericFile {
    static String userDir = FileImpl.userDir;

    factory GenericFile( String name ) {
        return FileImpl( name );
    }

    Future< String > readString( );

    void writeString( String contents );
}
```

**Flutter Project Structure:**
```
electron_flutter/
└── assets/
    └── text.txt
└── lib/
    ├── main.dart
	├── file_io.dart
	├── file_web.dart
	└── file.dart
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
name: elf
description: Electron Flutter application

environment:
  sdk: '>=3.3.1 <4.0.0'
  flutter: ">=1.17.0"

dependencies:
  flutter:
    sdk: flutter
  path: ^1.9.1

flutter:
  uses-material-design: true
```

**package.json**
```json
{
    "name": "elf",
    "version": "1.0.0",
    "description": "Electron Flutter application",
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
    "name": "elf",
    "short_name": "elf",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#0175C2",
    "theme_color": "#0175C2",
    "description": "Electron to Flutter project.",
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
cp ./assets/*.* ./build/web/assets
cd ./build/web/
npm start
```
