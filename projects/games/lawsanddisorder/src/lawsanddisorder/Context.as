package lawsanddisorder {

import com.whirled.WhirledGameControl;
import lawsanddisorder.component.*;

/**
 * Contains references to the various bits used in the game.
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
        var myId :int = _control.getMyId();
        _control.localChat(message + "\n");
        //_control.sendChat("\n[p " +  myId + "] " + message);
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
    	_control.sendMessage(Notices.BROADCAST, message);
    }
    
    protected var _control :WhirledGameControl;
    protected var _state :State;
    protected var _board :Board;
    protected var _eventHandler :EventHandler;
}
}