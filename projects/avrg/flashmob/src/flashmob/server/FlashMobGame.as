package flashmob.server {

import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flashmob.*;
import flashmob.party.*;

public class FlashMobGame
{
    public function FlashMobGame (partyId :int)
    {
        _partyId = partyId;
        _props = new PartyPropControl(_partyId, ServerContext.gameCtrl.game.props);
        _events.registerListener(_props, PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        _events.registerListener(_props, ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);

        _props.set(Constants.PROP_GAMESTATE, Constants.STATE_SPECTACLE_CREATOR);
    }

    public function shutdown () :void
    {
        // If another game for this party starts up, make sure it's not in a weird state
        _props.set(Constants.PROP_GAMESTATE, Constants.STATE_INIT);

        _events.freeAllHandlers();
        _props.shutdown();
    }

    public function get partyId () :int
    {
        return _partyId;
    }

    public function addPlayer (playerId :int) :void
    {
        if(!_players.add(playerId)) {
            log.warning("Tried to add a player to a game they were already in",
                "playerId", playerId,
                "partyId", _partyId);
        }
    }

    public function removePlayer (playerId :int) :void
    {
        if(!_players.remove(playerId)) {
            log.warning("Tried to remove player from a game they weren't in",
                "playerId", playerId,
                "partyId", _partyId);
        }
    }

    public function get numPlayers () :int
    {
        return _players.size();
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {

    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {

    }

    protected static function get log () :Log
    {
        return FlashMobServer.log;
    }

    protected var _partyId :int;
    protected var _players :HashSet = new HashSet();
    protected var _props :PartyPropControl;
    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}
