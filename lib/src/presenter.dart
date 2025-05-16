
// ignore_for_file: slash_for_doc_comments, constant_identifier_names

import 'data.dart';

abstract class Presenter {

    /**
     * Sends data to the model
     * 
     * arbitrary data object
     */
    void send( Data data );

    /**
     * After completing [send] and getting response from the model, updates views 
     */
    void update( Data data );

    /**
     * Closes execting mediator
     */
    void dispose( );
}
