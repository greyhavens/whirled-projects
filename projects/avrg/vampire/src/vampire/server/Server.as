package vampire.server
{
import com.threerings.util.Log;
import com.whirled.ServerObject;
import com.whirled.avrg.AVRServerGameControl;

import vampire.data.VConstants;

public class Server extends ServerObject
{
    public function Server ()
    {
        ServerContext.init(new AVRServerGameControl(this));

        //Start the game server
        var v :GameServer = new GameServer();
    }
}
}
