
import 'package:logger/logger.dart';

Logger getLogger( ) {
    return Logger( 
        printer: PrettyPrinter( printEmojis: false, printTime: true, colors: false ),
    );
}