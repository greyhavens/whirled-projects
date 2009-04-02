package vampire.server
{
import com.threerings.util.Log;
import com.whirled.ServerObject;
import com.whirled.avrg.AVRServerGameControl;

public class Server extends ServerObject
{
    public function Server ()
    {
        ServerContext.init(new AVRServerGameControl(this));

        Log.setLevel("", Log.INFO);

        //Start the game server
        var v :GameServer = new GameServer();
    }

}
}