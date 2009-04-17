package vampire.client
{
import com.threerings.util.HashMap;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.net.ElementChangedEvent;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import vampire.data.Codes;
import vampire.data.Lineage;

/**
 * Manages and presents room props and data.
 */
public class LineagesClient extends SimObject
{
    public function LineagesClient()
    {
        registerListener(ClientContext.ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED,
            handleElementChanged);

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



    override public function get objectName () :String
    {
        return NAME;
    }

    protected var _lineages :HashMap = new HashMap();


    public static const NAME :String = "RoomModel";
}
}