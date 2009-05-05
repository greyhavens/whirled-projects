package vampire.client
{
import com.threerings.util.HashMap;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.objects.BasicGameObject;
import com.whirled.net.ElementChangedEvent;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import vampire.client.events.LineageUpdatedEvent;
import vampire.data.Codes;
import vampire.data.Lineage;
import vampire.data.VConstants;

/**
 * Manages and presents room props and data.
 */
[Event(name="Lineage Updated", type="vampire.client.events.LineageUpdatedEvent")]
public class LineagesClient extends BasicGameObject
{
    public function LineagesClient()
    {
        registerListener(ClientContext.ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED,
            handleElementChanged);
        handleOurPlayerEnteredRoom(null);
        //Listen for the player leaving the room, shut down the client then
        registerListener(ClientContext.ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM,
            handleOurPlayerEnteredRoom);

        registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.PLAYER_LEFT,
            handlePlayerLeftRoom);

        registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.PLAYER_ENTERED,
            handlePlayerEnteredRoom);



        if (VConstants.LOCAL_DEBUG_MODE) {

            var lineage :Lineage = new Lineage();
            lineage.isConnectedToLilith = true;
                lineage.setPlayerSire(1, 2);
                lineage.setPlayerSire(3, 1);
                lineage.setPlayerSire(4, 1);
                lineage.setPlayerSire(5, 1);
                lineage.setPlayerSire(6, 5);
                lineage.setPlayerSire(7, 6);
                lineage.setPlayerSire(8, 6);
                lineage.setPlayerSire(9, 1);
                lineage.setPlayerSire(10, 1);
                lineage.setPlayerSire(11, 1);
                lineage.setPlayerSire(12, 1);
                lineage.setPlayerSire(13, 1);
                lineage.setPlayerSire(14, 1);
//            var msg :LineageUpdatedEvent = new LineageUpdatedEvent(lineage, ClientContext.ourPlayerId);
//            ClientContext.model.lineage = lineage;
//            ClientContext.model.dispatchEvent(msg);

            _lineages.put(ClientContext.ourPlayerId, lineage);
        }
    }

    protected function handlePlayerLeftRoom (e :AVRGameRoomEvent) :void
    {
        _lineages.remove(e.value);
    }

    protected function handlePlayerEnteredRoom (e :AVRGameRoomEvent) :void
    {
        var dict :Dictionary = ClientContext.ctrl.room.props.get(Codes.ROOM_PROP_PLAYER_LINEAGE) as Dictionary;
        if (dict != null) {
            loadLineageFromBytes(e.value as int, dict[e.value]);
        }
    }

    protected function handleOurPlayerEnteredRoom (...ignored) :void
    {
        var dict :Dictionary = ClientContext.ctrl.room.props.get(Codes.ROOM_PROP_PLAYER_LINEAGE) as Dictionary;
        if (dict != null) {
            for each (var playerId :int in ClientContext.ctrl.room.getPlayerIds()) {
                loadLineageFromBytes(playerId, dict[playerId]);
            }
        }
    }

    protected function handleElementChanged (e :ElementChangedEvent) :void
    {
        //Why do I have to do this?  Is there a race condidtion, where the game is shutdown
        //but it's still receiving updates?
        if (!ClientContext.ctrl.isConnected()) {
            return;
        }

        if(e.name == Codes.ROOM_PROP_PLAYER_LINEAGE) {
            var bytes :ByteArray = e.newValue as ByteArray;
            loadLineageFromBytes(e.key, bytes);

            //Upload all new lineages to the furniture
//            if (ClientContext.gameMode.furnNotifier != null) {
//                ClientContext.gameMode.furnNotifier.uploadLineageToFurnIfPresent(
//                    _lineages.get(e.key));
//            }
            dispatchEvent(new LineageUpdatedEvent(_lineages.get(e.key)));
        }
    }

    protected function loadLineageFromBytes (playerId :int, bytes :ByteArray) :void
    {
        if (bytes != null) {
            bytes.position = 0;
            var lineage :Lineage = new Lineage();
            lineage.fromBytes(bytes);
            trace(ClientContext.model.name + " recieved lineage from " + playerId + "=" + lineage);
            _lineages.put(playerId, lineage);
        }
    }

    public function getLineage (playerId :int) :Lineage
    {
        return _lineages.get(playerId);
    }

    public function isLineage (playerId :int) :Boolean
    {
        return _lineages.containsKey(playerId);
    }

    protected var _lineages :HashMap = new HashMap();

}
}