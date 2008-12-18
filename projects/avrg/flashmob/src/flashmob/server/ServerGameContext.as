package flashmob.server {

import com.threerings.util.Log;

import flashmob.*;
import flashmob.party.*;

public class ServerGameContext
{
    public var modeStack :ServerModeStack;
    public var partyId :int;
    public var players :Array = [];
    public var props :PartyPropControl;
    public var inMsg :PartyMsgReceiver;
    public var outMsg :PartyMsgSender;

    public function get numPlayers () :int
    {
        return players.length;
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
}

}
