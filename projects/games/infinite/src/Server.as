//
// $Id$
//
// The server agent for @project@ - a game for Whirled

package {

	import com.whirled.ServerObject;
	import com.whirled.game.GameControl;
	
	import server.WorldServer;
		
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
	        _worldServer = new WorldServer(_control);
	    }
	    
	    protected var _worldServer :WorldServer;
	    protected var _control :GameControl;
	}
}
