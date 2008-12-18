package flashmob.server {

import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flashmob.*;
import flashmob.party.*;

public class FlashMobGame
{
    public function FlashMobGame (partyId :int)
    {
        _partyId = partyId;
        _props = new PartyPropControl(_partyId, ServerContext.gameCtrl.game.props);
        _inMsg = new PartyMsgReceiver(_partyId, ServerContext.gameCtrl.game);
        _outMsg = new PartyMsgSender(_partyId, ServerContext.gameCtrl.game);

        _events.registerListener(_props, PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        _events.registerListener(_props, ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);
        _events.registerListener(_inMsg, MessageReceivedEvent.MESSAGE_RECEIVED, onMsgReceived);

        init();
    }

    public function init () :void
    {
        this.gameState = INITIAL_GAME_STATE;
        updatePlayers();
    }

    public function shutdown () :void
    {
        // If another game for this party starts up, make sure it's not in a weird state
        this.gameState = Constants.STATE_INVALID;

        _events.freeAllHandlers();
        _props.shutdown();
        _inMsg.shutdown();
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

        updatePlayers();
    }

    public function removePlayer (playerId :int) :void
    {
        if(!_players.remove(playerId)) {
            log.warning("Tried to remove player from a game they weren't in",
                "playerId", playerId,
                "partyId", _partyId);
            return;
        }

        // If we still have players in the game, tell them that we need to reset
        // the game.
        if (this.numPlayers > 0 && this.gameState != Constants.STATE_SPECTACLE_CHOOSER) {
            _outMsg.sendMessage(Constants.MSG_RESETGAME);
            init(); // updatePlayers() will be called here
        }
    }

    protected function updatePlayers () :void
    {
        _props.set(Constants.PROP_PLAYERS, _players.toArray());
    }

    public function get numPlayers () :int
    {
        return _players.size();
    }

    protected function set gameState (val :int) :void
    {
        log.info("Changing game state", "partyId", _partyId, "state", val);
        _props.set(Constants.PROP_GAMESTATE, val, true);
    }

    protected function get gameState () :int
    {
        return _props.get(Constants.PROP_GAMESTATE) as int;
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {

    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {

    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {

    }

    protected static function get log () :Log
    {
        return FlashMobServer.log;
    }

    protected var _partyId :int;
    protected var _players :HashSet = new HashSet();
    protected var _props :PartyPropControl;
    protected var _inMsg :PartyMsgReceiver;
    protected var _outMsg :PartyMsgSender;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static const INITIAL_GAME_STATE :int = Constants.STATE_SPECTACLE_CREATOR;
}

}
