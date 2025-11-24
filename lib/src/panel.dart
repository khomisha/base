// ignore_for_file: slash_for_doc_comments

import 'package:flutter/material.dart';

/**
 * Base panel
 */
class Panel extends StatefulWidget {
    final String title;
    final Widget childWidget;
    final List< Widget >? actions;
    final Icon? icon;

    const Panel( 
        { super.key, required this.title, required this.childWidget, this.icon, this.actions } 
    );

    @override
    State< Panel > createState( ) => _PanelState( );
}

class _PanelState extends State< Panel > {

    @override
    Widget build( BuildContext context ) {
        return Center( child: widget.childWidget );
    }
}
