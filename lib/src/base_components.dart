
// ignore_for_file: slash_for_doc_comments

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'injection_object.dart';
import 'widget_presenter.dart';
import 'facing.dart';
import 'style.dart';
import 'util.dart';

/**
 * The base list with form to edit selected list item
 */
abstract class BaseList< V extends WidgetPresenter > extends StatelessWidget {
    final Agent agent = Agent( );
    final bool addBtnVisible;

    BaseList( { super.key, this.addBtnVisible = false } );

    @override
    Widget build( BuildContext context ) {
        var presenter = context.watch< V >( );
        agent.presenter = presenter;

        Widget buildList( BuildContext context, int index ) {
            var delete = SlidableAction(
                onPressed: ( _ ) { presenter.delete( index ); },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete'
            );
            var edit = SlidableAction(
                onPressed: ( _ ) { presenter.startEdit( index ); },
                backgroundColor: Style.theme.primaryColor,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit'
            );
            var decoration = BoxDecoration( 
                border: Border.all( 
                    width: 1, 
                    color: presenter.list[ index ].selected ? Colors.pink : Style.theme.primaryColor 
                ),
                borderRadius: Style.borderRadius
            );
            var key = presenter.list[ index ].customData.attributes.keys.toList( )[ 0 ];
            var tile = ListTile( 
                title: Text( 
                    presenter.list[ index ].customData.attributes[ key ], 
                    style: Style.listTileStyle 
                ),
                onTap: ( ) { presenter.select( index ); }
            );
            var item = Container(
                decoration: decoration,
                width: MediaQuery.of( context ).size.width,
                height: 50,
                child: Center( child: tile )
            );
            var slidable = Slidable( 
                enabled: presenter.list[ index ].selected,
                endActionPane: ActionPane( motion: const DrawerMotion( ), children: [ edit, delete ] ), 
                child: item
            );
            return Padding( padding: const EdgeInsets.all( 6.0 ), child: slidable );
        }
        var listWidget = presenter.list.isNotEmpty ? 
            ListView.builder( itemCount: presenter.list.length, itemBuilder: buildList ) : 
            getStub( "List is Empty" );
        var btnAdd = ElevatedButton(
            onPressed: add,
            style: Style.styleButton, 
            child: const Text( "Add" )
        );
        var row = Row( mainAxisAlignment: MainAxisAlignment.end, children: < Widget > [ btnAdd ] );
        var column = Column( 
            children: [ 
                Expanded( child: listWidget ), 
                Padding( 
                    padding: const EdgeInsets.all( 16.0 ), 
                    child: Visibility( visible: presenter.readOnly && addBtnVisible, child: row )
                ) 
            ] 
        );
        var msvc = MultiSplitViewController( areas: [ Area( minimalSize: 150 ), Area( minimalSize: 250 ) ] );
        var multiSplit = MultiSplitView( controller: msvc, children: [ column, getForm( ) ] );
        var msvt = MultiSplitViewTheme(
            data: MultiSplitViewThemeData( dividerPainter: Style.divPainter, dividerThickness: 5 ),
            child: multiSplit
        );
        return msvt;
    }

    /**
     * Returns form to edit specified list item
     * index the list item index
     */
    T getForm< T extends BaseForm >( );

    /**
     * Adds new list item
     */
    void add( ) {
        agent.presenter.add( );
    }
}

/**
 * The base form
 */
abstract class BaseForm< T extends WidgetPresenter > extends StatelessWidget {
    final _fields = < String, Field > { };
    final Agent agent = Agent( );

    BaseForm( { super.key } );

    @override
    Widget build( BuildContext context ) {  
        var presenter = context.watch< T >( );
        agent.presenter = presenter;
        var widgets = < Widget > [];
        if( presenter.selectedIndex < 0 ) {
            widgets.add( Container( ) );
        } else {
            var containers = < String, WidgetContainer > { };
            for( String attributeName in getPattern( presenter.dataType ).keys.toList( ) ) {
                var field = createField( attributeName, presenter.selectedIndex );
                _fields[ attributeName ] = field;
                var pattern = getPattern( presenter.dataType )[ attributeName ]!;
                if( pattern.containerId != "" ) {   
                    var container = containers.putIfAbsent( 
                        pattern.containerId, 
                        ( ) { 
                            var wc = WidgetContainer( axis: pattern.axis );
                            widgets.add( wc );
                            return wc; 
                        } 
                    );
                    container.add( field );
                } else {
                    widgets.add( field );
                }
            }
            var buttonBar = ButtonBar(
                buttonHeight: 50,
                children: < Widget > [ getButton( onOK, "OK" ), getButton( onCancel, "Cancel" ) ]
            );
            widgets.add( Visibility( visible: !presenter.readOnly, child: buttonBar ) );
            addExtra( widgets );
        }
        return ListView(
            padding: const EdgeInsets.symmetric( horizontal: 32, vertical: 6 ),
            children: widgets
        );
    }

    /**
     * Adds extra widgets
     * widgets the widget list
     */
    void addExtra( List< Widget > widgets ) {
    }

    /**
     * Creates form field for specified data attribute
     * attributeName the attribute name
     */
    Field createField( String attributeName, int index ) {
        late Field field;
        var pattern = getPattern( agent.presenter.dataType )[ attributeName ]!;
        var data = agent.presenter.get( index ).customData;

        switch( pattern.style ) {
            case TEXT_FIELD:
                field = Field.textField( 
                    value: data[ attributeName ], 
                    pattern: pattern
                );
               break;
            default:
                field = Field( followup: pattern.style ?? "" );
        }
        return field;
    }

    /**
     * Action on press form OK button
     */
    void onOK( ) {
		for( String attributeName in getPattern( agent.presenter.dataType ).keys.toList( ) ) {
            var field = _fields[ attributeName ];
            if( field!.nativeField is TextBox ) { 
                var value = field.accessObj.innerObj.controller!.text;
                if( value != null ) {
                    if( !field.nativeField.fieldKey.currentState!.validate( ) ) {
                        return;
                    }
                    agent.presenter.update(
                        attributeName, 
                        fromString( field.nativeField.value.runtimeType, value ), 
                        false
                    );
                }
            }
        }
        agent.presenter.endEdit( true );
    }

    /**
     * Action on press form Cancel button
     */
    void onCancel( ) {
        agent.presenter.endEdit( false );
    }

    /**
     * Start edit
     */
    void edit( ) {
        agent.presenter.startEdit( 0 );
    }
}

/**
 * The agent which keeps reference on presenter
 */
class Agent {
    late WidgetPresenter presenter;

}

typedef IsSelected = bool Function( String name ) ;
typedef OnSelected = Function( ListItem listItem );

/**
 * Retuns button
 * function the function executing on press event
 * name the button label
 */
ElevatedButton getButton( void Function( ) function, String name ) {
    return ElevatedButton( 
        onPressed: ( ) { function( ); }, 
        style: Style.styleButton, 
        child: Text( name ) 
    );
}

/**
 * The form field
 */
class Field extends StatelessWidget {
    late final dynamic nativeField;
    final InjectionObject accessObj = InjectionObject( );

    Field( { super.key, String followup = "" } ) {
        nativeField = FieldStub( followup: followup );
    }

    /**
     * key the unique identifier see [Widget]
     * label the field label
     * value the field value
     * pattern the field pattern [FieldPattern]
     * readOnly the read only flag, default false
     */
    Field.textField( 
        { 
            super.key, 
            value, 
            required FieldPattern pattern, 
            bool readOnly = false 
        } 
    ) {
        nativeField = TextBox( 
            value: value, pattern: pattern, readOnly: readOnly, accessObj: accessObj 
        );
    }

    Field.chipListField( 
        { 
            super.key, 
            value, 
            required FieldPattern pattern, 
            required IsSelected isSelected, 
            required OnSelected onSelected 
        } 
    ) {
        nativeField = ChipListField( 
            value: value, 
            pattern: pattern, 
            isSelected: isSelected, 
            onSelected: onSelected
        );
    }

    @override
    Widget build( BuildContext context ) {
        return Padding( 
            padding: const EdgeInsets.symmetric( vertical: 15.0 ), 
            child: nativeField.build( context ) 
        );
    }
}

/**
 * The text form field wrapper
 */
class TextBox extends StatelessWidget {
    final dynamic value;
    final FieldPattern pattern;
    final GlobalKey< FormFieldState > fieldKey = GlobalKey( );
    final bool readOnly;
    final InjectionObject accessObj;

    TextBox( 
        { 
            super.key, 
            this.value, 
            required this.pattern, 
            required this.readOnly,
            required this.accessObj
        } 
    );

    @override
    Widget build( BuildContext context ) {
        var widget = TextFormField( 
            key: fieldKey,
            controller: TextEditingController( text: value.toString( ) ),
            decoration: Style.inputDecor.copyWith( labelText: pattern.label ),
            style: Style.formFieldStyle,
            maxLines: null,
            readOnly: readOnly,
            validator: pattern.validator
        );
        accessObj.innerObj = widget;
        return widget;
    }
}

/**
 * The chip list field
 */
class ChipListField extends StatelessWidget {
    final dynamic value;
    final FieldPattern pattern;
    final IsSelected isSelected;
    final OnSelected onSelected;
    final bool showCheckmark;

    const ChipListField( 
        { 
            super.key, 
            this.value, 
            required this.pattern,
            required this.isSelected,
            required this.onSelected,
            this.showCheckmark = true
        } 
    );

    @override
    Widget build( BuildContext context ) {
        return ChipList( 
            text: pattern.label, 
            list: value,
            width: pattern.width, 
            isSelected: isSelected,
            onSelected: onSelected,
            showCheckmark: showCheckmark
        );
    }
}

/**
 * The chip list with title
 */
class ChipList extends StatelessWidget {
    final List< ListItem > list;
    final double width;
    final IsSelected isSelected;
    final OnSelected onSelected;
    final bool showCheckmark;
    final String text;

    const ChipList( 
        { 
            super.key, 
            required this.text, 
            required this.list, 
            this.width = 130, 
            required this.isSelected, 
            required this.onSelected, 
            this.showCheckmark = false 
        } 
    );

    Widget _buildList( BuildContext context, int index ) {
        var name = list[ index ].customData.attributes[ 'name' ];
        var filterChip = FilterChip(
            selected: isSelected( name ),
            label: SizedBox( width: width - 5.0, child: Text( name ) ),
            onSelected: ( selected ) {
                onSelected( list[ index ] );
            },
            side: BorderSide( color: Style.theme.primaryColor ),
            backgroundColor: Colors.white,
            selectedColor: Style.theme.primaryColor,
            showCheckmark: showCheckmark
        );
        return Padding( padding: const EdgeInsets.all( 3 ), child: filterChip );
    }

    @override
    Widget build( BuildContext context ) {
        var chipList = ListView.builder( 
            scrollDirection: Axis.vertical, 
            itemCount: list.length, 
            itemBuilder: _buildList 
        );
        var title = Text( text, style: Style.listTileStyle, textAlign: TextAlign.start );
        var column = Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [ 
                Padding( padding: const EdgeInsets.all( 4 ), child: title ), 
                Expanded( child: chipList ) 
            ]
        );
        return Container( width: width, color: Colors.grey[ 60 ], child: column );
    }
}

/**
 * The widgets wrapper
 */
class WidgetContainer extends StatelessWidget {
    final _list = < Widget > [ ];
    final Axis axis;
    final Widget divider;

    WidgetContainer( 
        { super.key, this.axis = Axis.horizontal, this.divider = const SizedBox( width: 1 ) } 
    );

    @override
    Widget build( BuildContext context ) {
        var listView = ListView.separated(
            scrollDirection: axis,
            itemBuilder: ( BuildContext context, int index ) {
                return _list[ index ];
            }, 
            separatorBuilder: ( BuildContext context, int index ) => divider, 
            itemCount: _list.length
        );
        return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB( 0, 18, 0, 0 ),
            child: SizedBox( height: 320, child: listView )
        );
    }

    void add( Widget widget ) {
        _list.add( widget );
    }

    bool remove( Widget widget ) {
        return _list.remove( widget );
    }
}

/**
 * The field stab
 */
class FieldStub extends StatelessWidget {
    final String followup;

    const FieldStub( { super.key, this.followup = "" } );
  
    @override
    Widget build( BuildContext context ) {
        return getStub( "Not implemented $followup" );
    }
}

class SwiperPanel extends StatefulWidget {
    final List< Widget > widgets;
    final bool loop;
    final double? iconSize;

    // ignore: prefer_const_constructors_in_immutables
    SwiperPanel( { super.key, required this.widgets, this.loop = true, this.iconSize } );

    @override
    State< SwiperPanel > createState( ) => _SwiperPanelState( );
}

class _SwiperPanelState extends State< SwiperPanel > {
    int index = 0;
    int maxIndex = 0;
    bool disablePrev = false;
    bool disableNext = false;

    @override
    void initState( ) {
        super.initState( );
        maxIndex = widget.widgets.length;
        Functions.put( "changeMaxIndex", changeMaxIndex );
    }

    /**
     * Changes maxIndex, 
     * if bSet true set maxIndex to current index + 1, otherwise set maxIndex to widgets.length
     */
    void changeMaxIndex( bool bSet ) {
        setState( 
            ( ) { 
                maxIndex = bSet ? index + 1 : widget.widgets.length;
                disableNext = bSet;
            } 
        );
    }

    @override
    Widget build( BuildContext context ) {
        var arrows = Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: < Widget > [
                GestureDetector(
                    onTap: ( ) { setState( _movePrev ); },
                    child: Icon( 
                        Icons.arrow_left, 
                        size: widget.iconSize,
                        color: disablePrev ? Style.theme.colorScheme.primaryFixedDim : Style.theme.primaryColor
                    )
                ),
                GestureDetector(
                    onTap: ( ) { setState( _moveNext ); },
                    child: Icon( 
                        Icons.arrow_right, 
                        size: widget.iconSize,
                        color: disableNext ? Style.theme.colorScheme.primaryFixedDim : Style.theme.primaryColor
                    )
                )
            ]
        );
        var stack = Stack( 
            fit: StackFit.expand,
            children: [ widget.widgets[ index ], SizedBox.expand( child: arrows ) ]
        );
        return stack;
    }

    void _movePrev( ) {
        if( index == 0 ) {
            if( widget.loop ) {
                index = maxIndex - 1;
            }
        } else {
            if( index == 1 && !widget.loop ) { 
                disablePrev = true;
            }
            disableNext = false;
            index -= 1;
        }
    }

    void _moveNext( ) {
        if( index == maxIndex - 1 ) {
            if( widget.loop ) {
                index = 0;
            }
        } else {
            if( index == maxIndex - 2 && !widget.loop ) {
                disableNext = true;
            }
            disablePrev = false;
            index += 1;
        }
    }
}

