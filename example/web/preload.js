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
