package vampire.client
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.EntityControl;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AgentSubControl;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import vampire.client.events.LineageUpdatedEvent;
import vampire.client.events.PlayersFeedingEvent;
import vampire.data.Codes;
import vampire.data.Lineage;
import vampire.data.VConstants;
import vampire.feeding.PlayerFeedingData;


/**
 * The game and subgames interact with the agent code and properties via this class.
 *
 */

[Event(name="Hierarchy Updated", type="vampire.client.events.LineageUpdatedEvent")]
public class GameModel extends SimObject
{
    public function setup () :void
    {
        _agentCtrl = ClientContext.ctrl.agent;
        _propsCtrl = ClientContext.ctrl.room.props;

        registerListener(_propsCtrl, PropertyChangedEvent.PROPERTY_CHANGED, handlePropChanged);
        registerListener(_propsCtrl, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);



        //Update the HUD when the room props come in.
        registerListener(ClientContext.ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM, playerEnteredRoom);


        //If the room props are already present, update the HUD now.
        if(SharedPlayerStateClient.isProps(ClientContext.ourPlayerId)) {
            playerEnteredRoom();
        }
    }

    public function playerEnteredRoom(...ignored) :void
    {
        if(lineage == null) {
            _lineage = loadHierarchyFromProps();
            dispatchEvent(new LineageUpdatedEvent(_lineage));
        }
        else {
            log.warning("Player entered room, but no minion hierarchy to load.");
        }
    }

    protected function loadHierarchyFromProps() :Lineage
    {
        log.debug(VConstants.DEBUG_MINION + " loadHierarchyFromProps()");
        var hierarchy :Lineage = new Lineage();

        var dict :Dictionary = ClientContext.ctrl.room.props.get(Codes.ROOM_PROP_MINION_HIERARCHY) as Dictionary;

        if(dict != null) {

            var playerId :int;
            for (var key:Object in dict) {//Where key==playerId

                playerId = int(key);
                if(dict[playerId] != null) {
                    var data :Array = dict[playerId] as Array;
                    var playerName :String = data[0];
                    var sireId :int = int(data[1]);
                    hierarchy.setPlayerSire(playerId, sireId);
                    hierarchy.setPlayerName(playerId, playerName);
                }

            }
        }
        else {
            log.debug(VConstants.DEBUG_MINION + " loadHierarchyFromProps()", "dict==null");
        }
        hierarchy.recomputeMinions();
        log.debug(VConstants.DEBUG_MINION + " loadHierarchyFromProps()", "hierarchy", hierarchy);
        return hierarchy;
    }

    protected function handlePropChanged (e :PropertyChangedEvent) :void
    {
        switch (e.name) {
            case Codes.ROOM_PROP_MINION_HIERARCHY://) {//|| e.name == Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS) {
            _lineage = loadHierarchyFromProps();
            dispatchEvent(new LineageUpdatedEvent(_lineage));
            break;

            case Codes.ROOM_PROP_PLAYERS_FEEDING_UNAVAILABLE:
            var p :Array = playersFeeding;
            dispatchEvent(new PlayersFeedingEvent(p));
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

        if(e.name == Codes.ROOM_PROP_MINION_HIERARCHY) {

            _lineage = loadHierarchyFromProps();
            dispatchEvent(new LineageUpdatedEvent(_lineage));
            return;
        }

        //Otherwise check for player updates
        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName(e.name);


        if(!isNaN(playerIdUpdated)) {

//            //If a state change comes in, inform the avatar
//            if(e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_AVATAR_STATE) {
//
//                var entityAvatarId :String = ClientContext.getPlayerEntityId(playerIdUpdated);
//
//                var setStateFunction :Function = ClientContext.ctrl.room.getEntityProperty(
//                    AvatarGameBridge.ENTITY_PROPERTY_SETSTATE_FUNCTION, entityAvatarId) as Function;
//
//                if(setStateFunction != null) {
//                    log.debug("From room props " + playerIdUpdated + ", action=" + ClientContext.model.state +
//                        ", setStateFunction() " + e.newValue.toString());
//                    setStateFunction(e.newValue.toString());
//                }
//                else {
//                    log.error("handleElementChanged, setStateFunction==null, crusty avatar??", "e",
//                        e, "entityAvatarId", entityAvatarId, "playerIdUpdated", playerIdUpdated);
//                }
//
//            }



        }
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

    public function get bloodbonded() :int
    {
        if(VConstants.LOCAL_DEBUG_MODE) {
           return 1;
        }
        else {
            return SharedPlayerStateClient.getBloodBonded(ClientContext.ourPlayerId);
        }
    }

    public function get bloodbondedName() :String
    {
        if(VConstants.LOCAL_DEBUG_MODE) {
            return "Bloodbond name";
        }
        else {
            var name :String = SharedPlayerStateClient.getBloodBondedName(ClientContext.ourPlayerId);
            return name != null && name.length > 0 ? name : "No bloodbond yet.";
        }

    }

    public function get blood() :Number
    {
        return SharedPlayerStateClient.getBlood(ClientContext.ourPlayerId);
    }

    public function get bloodType() :int
    {
        return SharedPlayerStateClient.getBloodType(ClientContext.ourPlayerId);
    }

    public function get maxblood() :Number
    {
        return SharedPlayerStateClient.getMaxBlood(ClientContext.ourPlayerId);
    }

    public function get level() :int
    {
        return SharedPlayerStateClient.getLevel(ClientContext.ourPlayerId);
    }

    public function get sire() :int
    {
        if (_lineage != null) {
            return _lineage.getSireId(ClientContext.ourPlayerId);
        }
        return 0;
    }

    public function get invites() :int
    {
        return SharedPlayerStateClient.getInvites(ClientContext.ourPlayerId);
    }

    public function get location() :Array
    {
        var avatar :AVRGameAvatar = ClientContext.ctrl.room.getAvatarInfo(ClientContext.ourPlayerId);
        if(avatar != null) {
            return [avatar.x, avatar.y, avatar.z, avatar.orientation];
        }
        return null;
    }

    public function getLocation (playerId :int) :Array
    {
        var avatar :AVRGameAvatar = ClientContext.ctrl.room.getAvatarInfo(playerId);
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
        return SharedPlayerStateClient.getXP(ClientContext.ourPlayerId);
    }

    public function get time() :int
    {
        return SharedPlayerStateClient.getTime(ClientContext.ourPlayerId);
    }

    public function get name() :String
    {
        if(VConstants.LOCAL_DEBUG_MODE) {
            return "Player Name";
        }
        else {
            return ClientContext.ctrl.room.getAvatarInfo(ClientContext.ourPlayerId).name;
        }
    }

//    /**
//     * Set the avatar target.  That way, when the avatar arrived at it's destination, it
//     * will set it's orientation the same as the target's orientation.
//     */
//    public function set standBehindTarget (targetId :int) :void
//    {
//        _avatarStandBehindTargetId = targetId;
////        var setTargetFunction :Function = ClientContext.ctrl.room.getEntityProperty(
////            AvatarGameBridge.ENTITY_PROPERTY_SET_STAND_BEHIND_ID_FUNCTION, ClientContext.ourEntityId) as Function;
////        if(setTargetFunction != null) {
////            setTargetFunction(targetId);
////        }
////        else {
////            log.error("Cannot set avatar stand behind target as the function is null, targetId=" + targetId);
////        }
//    }

    public function get state() :String
    {
        return SharedPlayerStateClient.getCurrentState(ClientContext.ourPlayerId);
    }

    public function isNewPlayer() :Boolean
    {
        return time <= 1;
    }

    public function isVampire() :Boolean
    {
        return VConstants.LOCAL_DEBUG_MODE || level >= VConstants.MINIMUM_VAMPIRE_LEVEL;
    }

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
    protected var _propsCtrl :PropertyGetSubControl;




    protected static var log :Log = Log.getLog(GameModel);

}
}