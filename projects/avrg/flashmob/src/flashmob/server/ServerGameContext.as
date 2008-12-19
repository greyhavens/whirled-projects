package flashmob.server {

import com.threerings.util.Log;

import flashmob.*;
import flashmob.data.Spectacle;
import flashmob.party.*;

public class ServerGameContext
{
    public var game :ServerGame;
    public var partyId :int;
    public var playerIds :Array = [];
    public var props :PartyPropControl;
    public var inMsg :PartyMsgReceiver;
    public var outMsg :PartyMsgSender;

    public function get numPlayers () :int
    {
        return playerIds.length;
    }

    public function set spectacle (val :Spectacle) :void
    {
        _spectacle = val;
        props.set(Constants.PROP_SPECTACLE, val.toBytes());
        log.info("Spectacle updated");
    }

    public function get spectacle () :Spectacle
    {
        return _spectacle;
    }

    public function set waitingForPlayers (val :Boolean) :void
    {
        log.info("Waiting for players: " + val);
        props.set(Constants.PROP_WAITINGFORPLAYERS, val, true);
    }

    public function get waitingForPlayers () :Boolean
    {
        return props.get(Constants.PROP_WAITINGFORPLAYERS) as Boolean;
    }

    protected static function get log () :Log
    {
        return FlashMobServer.log;
    }

    protected var _spectacle :Spectacle;
}

}
