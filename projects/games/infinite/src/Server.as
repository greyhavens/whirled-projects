//
// $Id$
//
// The server agent for @project@ - a game for Whirled

package {

	import com.whirled.ServerObject;
	import com.whirled.game.GameControl;
	
	import whirled.ArbitrationServer;
	import whirled.ServerPlayerRegister;
	
	/**
	 * The server agent for @project@. Automatically created by the 
	 * whirled server whenever a new game is started. 
	 */
	public class Server extends ServerObject
	{
	    /**
	     * Constructs a new server agent.
	     */
	    public function Server ()
	    {
	        _control = new GameControl(this);	        
	        _arbiter = new ArbitrationServer(_control.net);
	        _players = new ServerPlayerRegister(_control.game);
	    }
	    
	    protected var _players :ServerPlayerRegister;
//
		protected var _arbiter :ArbitrationServer
//	
	    protected var _control :GameControl;
	}
}
