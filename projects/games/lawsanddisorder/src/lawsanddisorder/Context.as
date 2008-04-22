package lawsanddisorder {

import com.whirled.game.GameControl;

import lawsanddisorder.component.*;

/**
 * Contains references to the various bits used in the game.
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
     * Display an in-game notice message to all other players
     * TODO watchers don't see this message
     */
    public function broadcastOthers (message :String) :void
    {
    	for each (var player :Player in board.players) {
    		if (player != board.player) {
                _control.net.sendMessage(Notices.BROADCAST, message, player.serverId);
    		}
    	}
    }
    
    /**
     * Wrapper for sending messages through the WhirledGameControl
     */
    public function sendMessage (type :String, value :*) :void
    {
    	_control.net.sendMessage(type, value);
    }
    
    /**
     * Kick this player from the game.     */
    public function kickPlayer () :void
    {
        _control.local.backToWhirled();
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