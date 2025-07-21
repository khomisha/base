// main.js

// Modules to control application life and create native browser window
const { app, BrowserWindow, ipcMain } = require( 'electron' )
const path = require( 'node:path' )
const fs = require( 'fs/promises' );
const fsSync = require( 'fs' );

// app.commandLine.appendSwitch( 'enable-logging' )
// app.commandLine.appendSwitch( 'log-level', '0' )

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
    browser = new BrowserWindow(
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
            },
            //titleBarStyle: 'hidden'
        }
    )

    mainWindow.setMenuBarVisibility( false );
    browser.setMenuBarVisibility( false );
    
    mainWindow.on( "closed", 
        ( ) => {
            browser.destroy( );
        }
    );

    browser.on( "close", ( event ) => { event.preventDefault( ) } );

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
