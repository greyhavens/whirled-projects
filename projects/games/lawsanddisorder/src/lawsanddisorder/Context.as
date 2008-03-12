package lawsanddisorder {

import com.whirled.game.GameControl;

import lawsanddisorder.component.*;

/**
 * Contains references to the various bits used in the game.
 * TODO move notices, get, sendMessage, etc to EventHandler
 */
public class Context
{
    public function Context (control :GameControl)
    {
        _control = control;
    }
    
    public function get control () :GameControl
    {
        return _control;
    }

    /**
     * Log this debugging message
     * TODO combine log, notice, broadcast into one method?
     */
    public function log (message :String) :void
    {
        _control.local.feedback(message + "\n");
    }
    
    /**
     * Display an in-game notice message to the player
     */
    public function notice (notice :String) :void
    {
		board.notices.addNotice(notice);
		log("[notice] " + notice);
    }

    /**
     * Display an in-game notice message to all players or to one specific player
     */
    public function broadcast (message :String, player :Player = null) :void
    {
    	if (player != null) {
    	   _control.net.sendMessage(Notices.BROADCAST, message, player.serverId);
    	}
    	else {
    		_control.net.sendMessage(Notices.BROADCAST, message);
    	}
    }
    
    /**
     * Wrapper for sending messages through the WhirledGameControl
     */
    public function sendMessage (type :String, value :*) :void
    {
    	_control.net.sendMessage(type, value);
    }
    
    /** Connection to the game server */
    protected var _control :GameControl;
    
    /** Controls the user interface and player actions */
    public var state :State;
    
    /** Contains game components such as players, deck, laws */
    public var board :Board;
    
    /** Wraps incoming data and message events from the server */
    public var eventHandler :EventHandler;
}
}