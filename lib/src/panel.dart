// ignore_for_file: slash_for_doc_comments

import 'package:flutter/material.dart';

/**
 * Base panel
 */
class Panel extends StatefulWidget {
    final String title;
    final Widget childWidget;
    final List< Widget >? menu;
    final Icon? icon;

    const Panel( 
        { super.key, required this.title, required this.childWidget, this.icon, this.menu } 
    );

    @override
    State< Panel > createState( ) => _PanelState( );
}

class _PanelState extends State< Panel > {

    @override
    Widget build( BuildContext context ) {
        var appBar = AppBar( title: Text( widget.title ), actions: widget.menu );
        return Scaffold( appBar: appBar, body: Center( child: widget.childWidget ) );
    }
}
