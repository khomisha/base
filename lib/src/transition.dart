
// Interface for objects that have a state.
import 'logger.dart';

abstract class HasState {

    /**
	 * Returns current state
	 */
    int getState( );

    /**
	 * Sets state
	 * 
	 * state the state to set
	 */
    void setState( int state );
}

// Interface for transition commands executed before/after a state change.
abstract class TransitionCommand {

  	/**
	 * Executes some action before transition from one state to another is going on
	 * 
	 * target the transition target object
	 */
    Future< void > executeBefore( HasState target );

    /**
	 * Executes some action after transition from one state to another is completed
	 * 
	 * target the transition target object
	 */
    Future< void > executeAfter( HasState target ) async {}
}

/** State transition object.
 * The [transitionTable] is a 2D matrix where:
 * - rows represent the current state
 * - columns represent the new (target) state
 * - each cell holds the [TransitionCommand] to execute for that transition
 */
class Transition {
    List< List < TransitionCommand > >? _transitionTable;

    Transition( );

    Transition.withTable( List< List< TransitionCommand > > transitionTable ) {
        setTransitionTable( transitionTable );
    }

    /**
     * Performs a transition to [newState] on the given [target].
     * Executes [TransitionCommand.executeBefore] before the state change and
     * [TransitionCommand.executeAfter] after it. Logs the result.
     */
    Future< void > doTransition( int newState, HasState target ) async {
        final oldState = target.getState( );
        try {
            final tc = getTransitionCommand( newState, oldState );
            await tc.executeBefore( target );
            target.setState( newState );
            await tc.executeAfter( target );
            logger.fine( '$oldState -> ${target.getState()} success' );
        } 
        on UnsupportedError catch( e ) {
            logger.severe( '${e.message} — failure to change state: $newState' );
        } 
        on ArgumentError catch( e ) {
            logger.severe( '${e.message} — failure to change state: $newState' );
        }
        // FileNotFoundException equivalent: let other exceptions propagate
    }

    // Override to build and return the transition table.
    List< List< TransitionCommand > >? doTransitionTable( ) => null;

    List< List< TransitionCommand > >? getTransitionTable( ) => _transitionTable;

    void setTransitionTable( List< List< TransitionCommand > > transitionTable ) {
        _transitionTable = transitionTable;
    }

    /**
     * Returns the [TransitionCommand] for a given [currentState] → [newState] pair.
     */
    TransitionCommand getTransitionCommand( int newState, int currentState ) {
        return _transitionTable![ currentState ][ newState ];
    }
}

// A no-op command — does nothing before or after the transition.
class NoCommand extends TransitionCommand {
    NoCommand( );

    @override
    Future< void > executeBefore( HasState target ) async {}
}

/**
 * A guard command — throws [UnsupportedError] to block an illegal transition.
 */
class WrongCommand extends TransitionCommand {
    WrongCommand( );

    @override
     Future< void > executeBefore( HasState target ) {
        throw UnsupportedError( 'Wrong transition' );
    }
}
