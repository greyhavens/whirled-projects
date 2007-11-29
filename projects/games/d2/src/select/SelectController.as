package select {

import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.util.Assert;
import com.whirled.WhirledGameControl;

import def.BoardDefinition;
import def.PackDefinition;

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

    /** Called from the board display, when a new pack is selected. */
    public function packSelected (pack :PackDefinition) :void
    {
        Assert.isNotNull(_whirled);

        _whirled.set(BOARD_SELECT, null, _main.myIndex);  // clear out any previous board selection
    }

    /** Called from the board display, when a new board is selected. */
    public function boardSelected (board :BoardDefinition) :void
    {
        Assert.isNotNull(_whirled);

        _whirled.set(BOARD_SELECT, board.guid, _main.myIndex);
        // and we wait for the server round-trip...
    }

    /** Returns the guid of the board selected by the other player, or null for single-player. */
    public function getOpponentBoardGuid () :String
    {
        if (_main.isSinglePlayer) {
            return null;
        }

        var otherIndex :int = 1 - _main.myIndex;
        return _whirled.get(BOARD_SELECT, otherIndex) as String;
    }

    // from interface PropertyChangedListener
    public function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name != BOARD_SELECT) {
            return; // not for us!
        }
        
        // if we're just initializing a storage array, consume the event
        if (event.index == -1) {
            return;
        }

        var selectedGuid :String = event.newValue as String;
        
        // remember if it was my choice
        if (event.index == _main.myIndex) {
            _myBoardGuid = selectedGuid;
        }

        // inform the listener that a new board was picked
        _selected(event.index, selectedGuid);
        
        // if all boards agree, inform the other listener
        if (_myBoardGuid != null) {
            for (var ii :int = 0; ii < _main.playerCount; ii++) {
                if ((_whirled.get(BOARD_SELECT, ii) as String) != _myBoardGuid) {
                    return; // no match, we're done
                }
            }
            // they all match!
            _done(_myBoardGuid);
        }
    }

    protected var _myBoardGuid :String;
    
    protected var _main :Main;                
    protected var _whirled :WhirledGameControl;
    protected var _selected :Function, _done :Function;
}

}
