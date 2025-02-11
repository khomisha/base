
// ignore_for_file: slash_for_doc_comments, constant_identifier_names

abstract class Presenter {

    /**
     * Sends data to the model
     * 
     * arbitrary data object
     */
    void send( dynamic data );

    /**
     * After completing [send] and getting response from the model, updates views 
     */
    void update( dynamic data );

    /**
     * Closes execting mediator
     */
    void dispose( );
}
