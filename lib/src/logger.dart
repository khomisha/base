// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'logger_web.dart' if( dart.library.io ) 'logger_io.dart';

const String ERR_MSG = "error_message";
const String ERROR = "error";
const String WARNING = "warning";
const String NOTICE = "notice";
const String STACK = "stack_trace";

var logger = getLogger( );

void logOnErrorFlutter( FlutterErrorDetails details ) {
    logger.e( details.exception.toString( ), error: details.exception, stackTrace: details.stack );
}

bool logOnErrorPlatform( Object error, StackTrace stack ) {
    var err = error as Exception; 
    logger.e( err.toString( ), error: err, stackTrace: stack );
    return true;
}
