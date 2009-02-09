package vampire.server
{
    import com.threerings.util.Log;
    import com.whirled.ServerObject;
    import com.whirled.avrg.AVRServerGameControl;
    
    public class Server extends ServerObject
    {
        public function Server()
        {
            ServerContext.ctrl = new AVRServerGameControl( this );
            
            //Plug the client broadcaster to the Log
            ServerContext.serverLogBroadcast = new AVRGAgentLogTarget( ServerContext.ctrl );
            Log.addTarget( ServerContext.serverLogBroadcast );
            Log.setLevel("", Log.DEBUG);
            
            //Start the game server
            var v :VServer = new VServer();
        }

    }
}