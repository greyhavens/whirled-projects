package select {

import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.util.Assert;
import com.whirled.WhirledGameControl;

import def.BoardDefinition;

/**
 * Controller responsible for communicating board selections across the network.
 * It sends board selection updates across the network, and monitors other players' selections.
 */
public class SelectController
    implements PropertyChangedListener
{
    public static const BOARD_SELECT :String = "selectcontroller_boardselect";

    public function SelectController (main :Main)
    {
        _main = main;
    }
        
    /**
     * @param selected Callback that is called each time any of the players selects a board.
     *    If the board is owned by this player, passes the reference, otherwise passes null.
     *    It should have the signature: function (playerId :int, board :BoardDefinition) :void
     * @param done Callback that is called after all players selected a board. If the selection
     *    is unanimous, passes the board reference; otherwise passes null. The function should
     *    have the signature: function (board :BoardDefinition) :void
     */
    public function init (whirled :WhirledGameControl, selected :Function, done :Function) :void
    {
        Assert.isNull(_whirled);
        
        _whirled = whirled;
        _selected = selected;
        _done = done;

        _whirled.registerListener(this);
        if (_whirled.amInControl()) {
            // initialize storage
            _whirled.testAndSet(BOARD_SELECT, new Array(), null);
        }
    }

    public function shutdown () :void
    {
        Assert.isNotNull(_whirled);
        
        _whirled.unregisterListener(this);

        _whirled = null;
        _selected = null;
        _done = null;
    }

    public function handleClick (board :BoardDefinition) :void
    {
        Assert.isNotNull(_whirled);

        _whirled.set(BOARD_SELECT, board.guid, _main.myIndex);
        // and we wait for the server round-trip...
    }

    public function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == BOARD_SELECT) {

            // if we're just initializing the storage array, consume the event
            if (event.index == -1) {
                return;
            }

            var selectedGuid :String = event.newValue as String;
            
            // remember if it was my choice
            if (event.index == _main.myIndex) {
                _mySelection = selectedGuid;
            }

            // inform the listener that a new board was picked
            _selected(event.index, _main.defs.findBoard(selectedGuid));
            
            // if all boards agree, inform the other listener
            if (_mySelection != null) {
                for (var ii :int = 0; ii < _main.playerCount; ii++) {
                    if ((_whirled.get(BOARD_SELECT, ii) as String) != _mySelection) {
                        return; // no match, we're done
                    }
                }
                // they all match!
                _done(getMySelection());
            }

        }
    }

    /** Returns the board I've currently selected. */
    public function getMySelection () :BoardDefinition
    {
        return (_mySelection == null) ? null : _main.defs.findBoard(_mySelection);
    }
    
    protected var _mySelection :String;
    protected var _main :Main;                
    protected var _whirled :WhirledGameControl;
    protected var _selected :Function, _done :Function;
}

}
