package flashmob {

import flashmob.net.*;

public class AppContext
{
    public static var msgRegistry :MessageRegistry = new MessageRegistry();

    public static function init () :void
    {
        msgRegistry.addMessageType(LobbyRequest);
    }
}

}
