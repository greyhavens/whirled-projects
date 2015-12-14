package 
{
    import com.threerings.util.Log;
    import com.whirled.ServerObject;
    import com.whirled.contrib.simplegame.util.Rand;
    import com.whirled.game.GameControl;
    
    import joingame.AppContext;
    import joingame.JoingameServer;
    import joingame.net.JoinMessageManager;
    
    
    public class Server extends ServerObject
    {
        public function Server(gameControl: GameControl = null)
        {
            Log.setLevel("", Log.ERROR);
            
            
            AppContext.useServerAgent = true;
            AppContext.gameCtrl = new GameControl(this);
            AppContext.isConnected = AppContext.gameCtrl.isConnected();
            AppContext.messageManager = new JoinMessageManager( AppContext.gameCtrl );
            var gameserver :JoingameServer = new JoingameServer( AppContext.gameCtrl );
            
        }
    }
}