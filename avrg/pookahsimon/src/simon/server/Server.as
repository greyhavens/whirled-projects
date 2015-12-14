package simon.server {

import com.threerings.util.Log;

import com.whirled.contrib.avrg.oneroom.OneRoomGameServer;

import simon.data.Constants;

public class Server extends OneRoomGameServer
{
    public function Server ()
    {
        Log.getLog(this).info("Simon verson " + Constants.VERSION);
    }


    roomType = Game;
}
}
