
import 'dart:io';
import 'package:logger/logger.dart';
import 'config.dart';
import 'util.dart';

Logger getLogger( ) {
    return Logger( 
        printer: PrettyPrinter( printEmojis: false, printTime: true, colors: false ),
        output: FileOutput( file: File( createFileName( "logs", Config.config[ 'app_name' ], "log" ) ) )
    );
}
