// ignore_for_file: slash_for_doc_comments, constant_identifier_names

import 'file_web.dart' if( dart.library.io ) 'file_io.dart';

/**
 * File wrapper
 */
abstract class GenericFile {
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

    /**
     * Deletes this file
     */
    void delete( );

    /**
     * Copy source dir to destination recursively
     * source the source dir
     * destination the destination dir
     */
    static void copyDirectory( String source, String destination ) {
        FileImpl.copyDirectory( source, destination );
    }

    /**
     * Creates directory if it does not exist
     * path the path to dir
     */
    static void mkDir( String path ) {
        FileImpl.mkDir( path );
    }

    /**
     * Returns true if path is exist and false otherwise
     */
    static bool isExist( String path ) {
        return FileImpl.isExist( path );
    }

    /**
     * Returns selected file full path
     * title the dialog title
     * filterName the filter name
     * extensions the file extensions list
     * Usage:
     * ```   
        final path = await pickFile(
        title: 'Select audio file',
        filterName: 'Audio',
        extensions: ['mp3', 'wav', 'm4a'],
        );     
      ```  
    */
    static Future< String? > pickFile( 
        { 
            String title = 'Select file', 
            String filterName = "All Files", 
            List< String > extensions = const [ '*' ] 
        }
    ) {
        return FileImpl.pickFile( title, filterName, extensions );
    }
}