package flashmob.server {

import com.threerings.util.Log;
import com.whirled.contrib.avrg.oneroom.OneRoomGameServer;
import com.whirled.net.MessageReceivedEvent;

public class Server extends OneRoomGameServer
{
    public function Server ()
    {
        // tell OneRoomGameServer to instantiate our GameController class when a new
        // Bingo room is created
        //OneRoomGameServer.roomType = GameController;
    }
}

}
