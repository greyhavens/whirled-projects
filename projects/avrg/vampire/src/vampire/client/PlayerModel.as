package vampire.client
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.EntityControl;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AgentSubControl;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import flash.utils.ByteArray;

import vampire.client.events.LineageUpdatedEvent;
import vampire.client.events.PlayersFeedingEvent;
import vampire.data.Codes;
import vampire.data.Lineage;
import vampire.data.Logic;
import vampire.data.VConstants;
import vampire.feeding.PlayerFeedingData;


/**
 * The game and subgames interact with the agent code and properties via this class.
 *
 */

[Event(name="Hierarchy Updated", type="vampire.client.events.LineageUpdatedEvent")]
public class PlayerModel extends SimObject
{
    public function PlayerModel ()
    {
        _agentCtrl = ClientContext.ctrl.agent;
        _roomProps = ClientContext.ctrl.room.props;
        _playerProps = ClientContext.ctrl.player.props;

        if (_playerProps == null) {
            throw new Error("Player props cannot be null");
        }

        _lineage = new Lineage();

        registerListener(_roomProps, PropertyChangedEvent.PROPERTY_CHANGED, handleRoomPropChanged);
        registerListener(ClientContext.ctrl.player.props,
            PropertyChangedEvent.PROPERTY_CHANGED, handlePlayerPropChanged);
        registerListener(_playerProps, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);

        //Update the HUD when the room props come in.
//        registerListener(ClientContext.ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM, playerEnteredRoom);

        //If the room props are already present, update the HUD now.
//        if(SharedPlayerStateClient.isProps(ClientContext.ourPlayerId)) {
//            playerEnteredRoom();
//        }
    }

//    protected function playerEnteredRoom (...ignored) :void
//    {
//        if(lineage == null) {
//            _lineage = loadLineageFromProps();
//            dispatchEvent(new LineageUpdatedEvent(_lineage));
//        }
//        else {
//            log.warning("Player entered room, but no Lineage to load.");
//        }
//    }

//    protected function loadLineageFromProps() :Lineage
//    {
//        log.debug(" loadLineageFromProps()");
//        var lineage :Lineage = new Lineage();
//
//        var dict :Dictionary = ClientContext.ctrl.room.props.get(Codes.ROOM_PROP_LINEAGE) as Dictionary;
//
//        if(dict != null) {
//
//            var playerId :int;
//            for (var key:Object in dict) {//Where key==playerId
//
//                playerId = int(key);
//                if(dict[playerId] != null) {
//                    var data :Array = dict[playerId] as Array;
//                    var playerName :String = data[0];
//                    var sireId :int = int(data[1]);
//                    lineage.setPlayerSire(playerId, sireId);
//                    lineage.setPlayerName(playerId, playerName);
//                }
//
//            }
//        }
//        else {
//            log.debug(" loadLineageFromProps()", "dict==null");
//        }
//        lineage.recomputeProgeny();
//        log.debug(" loadLineageFromProps()", "hierarchy", lineage);
//        return lineage;
//    }

    protected function handleRoomPropChanged (e :PropertyChangedEvent) :void
    {
        switch (e.name) {
            case Codes.ROOM_PROP_PLAYERS_FEEDING_UNAVAILABLE:
            var p :Array = playersFeeding;
            dispatchEvent(new PlayersFeedingEvent(p));
            break;

            default:
            break;
        }
    }

    protected function handlePlayerPropChanged (e :PropertyChangedEvent) :void
    {
        switch (e.name) {
            case Codes.PLAYER_PROP_LINEAGE:
            _lineage = new Lineage();
            _lineage.fromBytes(e.newValue as ByteArray);
            trace("received new lineage=" + _lineage);
            dispatchEvent(new LineageUpdatedEvent(_lineage));
            break;

            default:
            break;
        }
    }



    protected function handleElementChanged (e :ElementChangedEvent) :void
    {
        //Why do I have to do this?  Is there a race condidtion, where the game is shutdown
        //but it's still receiving updates?
        if (!ClientContext.ctrl.isConnected()) {
            return;
        }

//        if(e.name == Codes.ROOM_PROP_LINEAGE) {
//            _lineage = loadLineageFromProps();
//            dispatchEvent(new LineageUpdatedEvent(_lineage));
//            return;
//        }
    }

    public function playerIdsInRoom() :Array
    {
        return ClientContext.ctrl.room.getPlayerIds();
    }

    public function isPlayerInRoom(playerId :int) :Boolean
    {
        return ArrayUtil.contains(playerIdsInRoom(), playerId);
    }

    public function isPlayer(userId :int) :Boolean
    {
        return ArrayUtil.contains(playerIdsInRoom(), userId);
    }

    public function get bloodbond() :int
    {
        if(VConstants.LOCAL_DEBUG_MODE) {
           return 1;
        }
        else {
            return _playerProps.get(Codes.PLAYER_PROP_BLOODBOND) as int;
//            return SharedPlayerStateClient.getBloodBonded(ClientContext.ourPlayerId);
        }
    }

    public function get bloodbondName() :String
    {
        if(VConstants.LOCAL_DEBUG_MODE) {
            return "Bloodbond name";
        }
        else {
            return _playerProps.get(Codes.PLAYER_PROP_BLOODBOND_NAME) as String;
//            var name :String = SharedPlayerStateClient.getBloodBondedName(ClientContext.ourPlayerId);
//            return name != null && name.length > 0 ? name : "No bloodbond yet.";
        }

    }

//    public function get blood() :Number
//    {
//        return SharedPlayerStateClient.getBlood(ClientContext.ourPlayerId);
//    }

    public function get bloodType() :int
    {
        return Logic.getPlayerBloodStrain(ClientContext.ourPlayerId) as int;
    }

    public function get maxblood() :Number
    {
        return Logic.maxBloodForLevel(level) as Number;
    }

    public function get level() :int
    {
        return Math.max(1, Logic.levelGivenCurrentXpAndInvites(xp, invites)) as int;
//        return SharedPlayerStateClient.getLevel(ClientContext.ourPlayerId);
    }

    public function get sire() :int
    {
        return _playerProps.get(Codes.PLAYER_PROP_SIRE) as int;
//        if (_lineage != null) {
//            return _lineage.getSireId(ClientContext.ourPlayerId);
//        }
//        return 0;
    }

    public function get invites() :int
    {
        return _playerProps.get(Codes.PLAYER_PROP_INVITES) as int;
//        return SharedPlayerStateClient.getInvites(ClientContext.ourPlayerId);
    }

    public function get location() :Array
    {
        var avatar :AVRGameAvatar = ClientContext.ctrl.room.getAvatarInfo(ClientContext.ourPlayerId);
        if(avatar != null) {
            return [avatar.x, avatar.y, avatar.z, avatar.orientation];
        }
        return null;
    }

    public function get avatar() :AVRGameAvatar
    {
        if (ClientContext.ctrl.room == null) {
            return null;
        }
        return ClientContext.ctrl.room.getAvatarInfo(ClientContext.ourPlayerId);
    }



    public function get xp() :Number
    {
        var value :Number = _playerProps.get(Codes.PLAYER_PROP_XP) as Number;
        return isNaN(value) ? 0 : value;
//        return SharedPlayerStateClient.getXP(ClientContext.ourPlayerId);
    }

//    public function get time() :int
//    {
//        return int(ClientContext.ctrl.player.props.get(Codes.PLAYER_PROP_LAST_TIME_AWAKE));
////        SharedPlayerStateClient.getTime(ClientContext.ourPlayerId);
//    }

    public function get name() :String
    {
        if(VConstants.LOCAL_DEBUG_MODE) {
            return "Player Name";
        }
        else {
            return ClientContext.ctrl.game.getOccupantName(ClientContext.ourPlayerId);
        }
    }

    public function get state() :String
    {
        return _playerProps.get(Codes.PLAYER_PROP_STATE) as String;
//        return SharedPlayerStateClient.getCurrentState(ClientContext.ourPlayerId);
    }

//    public function isNewPlayer() :Boolean
//    {
//        return time <= 1;
//    }

    public function get lineage() :Lineage
    {
        return _lineage;
    }

    //For debugging
    public function set lineage(h :Lineage) :void
    {
        _lineage = h;
    }

    public function get hotspot () :Array
    {
        var hotspot :Array = ClientContext.ctrl.room.getEntityProperty(
            EntityControl.PROP_HOTSPOT, ClientContext.ourEntityId) as Array;
        return hotspot;
    }

    public function getAvatarName (playerId :int) :String
    {
        var entityId :String = ClientContext.getPlayerEntityId(playerId);
        if (entityId != null) {
            var name :String = ClientContext.ctrl.room.getEntityProperty(
                EntityControl.PROP_NAME, entityId) as String;
            return name;
        }
        return null;
    }

    public function get playerFeedingData () :PlayerFeedingData
    {
        if(VConstants.LOCAL_DEBUG_MODE) {
            var dummy :PlayerFeedingData = new PlayerFeedingData();
            dummy.collectStrainFromPlayer(1, 1);
            dummy.collectStrainFromPlayer(3, 3);
            dummy.collectStrainFromPlayer(3, 3);
            dummy.collectStrainFromPlayer(3, 4);
            return dummy
        }

        var pfd :PlayerFeedingData = new PlayerFeedingData();
        var bytes :ByteArray = ClientContext.ctrl.player.props.get(Codes.PLAYER_PROP_FEEDING_DATA) as ByteArray;
        if (bytes != null) {
            bytes.position = 0;
            try {
                pfd.fromBytes(bytes);
            }
            catch(err :Error) {
                log.error(err.getStackTrace());
                return new PlayerFeedingData();
            }
        }

        return pfd;
    }

    public function get playersFeeding () :Array
    {
        var feedingPlayers :Array =
            ClientContext.ctrl.room.props.get(Codes.ROOM_PROP_PLAYERS_FEEDING_UNAVAILABLE) as Array;

        return feedingPlayers == null ? [] : feedingPlayers;
    }

    public function get primaryPreds () :Array
    {
        var preds :Array =
            ClientContext.ctrl.room.props.get(Codes.ROOM_PROP_PRIMARY_PREDS) as Array;

        return preds == null ? [] : preds;
    }

    public function setAvatarState (state :String) :void
    {
        log.debug(ClientContext.ourPlayerId + " setAvatarState", "state", state);
        ClientContext.ctrl.player.setAvatarState(state);
    }

    public function get roomAvatarIds () :Array
    {
        return ClientContext.ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR);
    }

    public function get playerIds () :Array
    {
        return ClientContext.ctrl.room.getPlayerIds();
    }


    protected var _lineage :Lineage;
    protected var _agentCtrl :AgentSubControl;
    protected var _playerProps :PropertyGetSubControl;
    protected var _roomProps :PropertyGetSubControl;




    protected static var log :Log = Log.getLog(PlayerModel);

}
}