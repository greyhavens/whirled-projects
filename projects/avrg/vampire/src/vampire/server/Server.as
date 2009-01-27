package vampire.server
{
    import com.whirled.ServerObject;
    import com.whirled.avrg.AVRServerGameControl;
    
    public class Server extends ServerObject
    {
        public function Server()
        {
            ServerContext.ctrl = new AVRServerGameControl( this );
            var v :VServer = new VServer();
        }

    }
}