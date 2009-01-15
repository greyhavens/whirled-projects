package flashmob.server {

import com.threerings.util.Log;

import flashmob.*;
import flashmob.data.*;
import flashmob.party.*;

public class ServerGameContext
{
    public var game :ServerGame;
    public var partyInfo :PartyInfo;
    public var players :PlayerSet = new PlayerSet();
    public var props :PartyPropControl;
    public var inMsg :PartyMsgReceiver;
    public var outMsg :PartyMsgSender;

    public function get allPlayersPresent () :Boolean
    {
        for each (var playerId :int in partyInfo.playerIds) {
            if (!players.containsPlayer(playerId)) {
                return false;
            }
        }

        return true;
    }

    public function get numAbsentPlayers () :int
    {
        var count :int;
        for each (var playerId :int in partyInfo.playerIds) {
            if (!players.containsPlayer(playerId)) {
                count++;
            }
        }

        return count;
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

    protected static function get log () :Log
    {
        return FlashMobServer.log;
    }

    protected var _spectacle :Spectacle;
}

}
