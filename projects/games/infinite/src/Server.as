//
// $Id$
//
// The server agent for @project@ - a game for Whirled

package {

	import com.whirled.ServerObject;
	import com.whirled.game.GameControl;
	
	import whirled.ArbitrationServer;
	
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
	    }

		protected var _arbiter :ArbitrationServer
	
	    protected var _control :GameControl;
	}
}
