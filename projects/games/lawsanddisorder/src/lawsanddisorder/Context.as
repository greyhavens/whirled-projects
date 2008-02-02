package lawsanddisorder {

import com.whirled.WhirledGameControl;
import lawsanddisorder.component.*;
import com.threerings.ezgame.UserChatEvent;

/**
 * Contains references to the various bits used in the game.
 * TODO move notices, get, sendMessage, etc to EventHandler
 */
public class Context
{
    public function get control () :WhirledGameControl
    {
        return _control;
    }

    public function get state () :State
    {
        return _state;
    }
    
    public function get board () :Board
    {
        return _board;
    }

    public function get eventHandler () :EventHandler
    {
        return _eventHandler;
    }
    
    public function Context (control :WhirledGameControl)
    {
        _control = control;
    }

    public function init (state :State, board :Board, eventHandler :EventHandler) :void
    {
        _state = state;
        _board = board;
        _eventHandler = eventHandler;
    }

    /**
     * Log this debugging message
     * TODO combine log, notice, broadcast into one method?
     */
    public function log (message :String) :void
    {
        var myId :int = _control.game.getMyId();
        _control.local.feedback(message + "\n");
    }
    
    /**
     * Display an in-game notice message to the player
     */
    public function notice (notice :String) :void
    {
		_board.notices.addNotice(notice);
		log("[notice] " + notice);
    }

    /**
     * Display an in-game notice message to all players
     */
    public function broadcast (message :String) :void
    {
    	_control.net.sendMessage(Notices.BROADCAST, message);
    }
    
    /**
     * Wrapper for sending messages through the WhirledGameControl     */
    public function sendMessage (type :String, value :*) :void
    {
    	_control.net.sendMessage(type, value);
    }
    
    protected var _control :WhirledGameControl;
    protected var _state :State;
    protected var _board :Board;
    protected var _eventHandler :EventHandler;
}
}