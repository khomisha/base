
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'config.dart';

const double BORDER_CIRCULAR = 7;

class Style {   
    static final ColorScheme _cs = ColorScheme.fromSeed( seedColor: guiColor );
    static final ThemeData _theme = ThemeData( 
        colorScheme: _cs,
        appBarTheme: AppBarTheme( backgroundColor: _cs.onInverseSurface )
    );
    static final ThemeData theme = ThemeData.localize(
        _theme, 
        _theme.typography.geometryThemeFor( ScriptCategory.englishLike ) 
    );
    static final BorderRadius borderRadius = BorderRadius.circular( BORDER_CIRCULAR );
    static final BoxDecoration boxDecor = BoxDecoration( 
        border: Border.all( width: 1, color: theme.primaryColor ),
        borderRadius: borderRadius
    );
    static final InputDecoration inputDecor = InputDecoration(
        border: const OutlineInputBorder( ),
        contentPadding: const EdgeInsets.symmetric( vertical: 20, horizontal: 12 ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide( color: theme.primaryColor, width: 1.25 ),
            borderRadius: borderRadius
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide( color: theme.primaryColor.withAlpha( 115 ) ),
            borderRadius: borderRadius
        ),
        labelStyle: theme.textTheme.labelLarge,
        errorBorder: OutlineInputBorder(
            borderSide: const BorderSide( color: Colors.pink ),
            borderRadius: borderRadius
        )
    );
    static final TextStyle listTileStyle = theme.textTheme.titleMedium!;
    static final DividerPainter divPainter = DividerPainters.grooved1( backgroundColor: theme.primaryColor );
    static final TextStyle formFieldStyle = theme.textTheme.bodyMedium!;
    static final TextStyle fieldStyle = theme.textTheme.bodyMedium!;
    static final TextStyle fieldLabelStyle = theme.textTheme.labelLarge!;
    static final ButtonStyle styleButton = ElevatedButton.styleFrom( 
        minimumSize: const Size( 89.0, 50.0 ), 
        textStyle: listTileStyle 
    );
}
