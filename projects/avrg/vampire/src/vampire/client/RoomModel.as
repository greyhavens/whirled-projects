package vampire.client
{
import com.threerings.util.HashMap;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.utils.ByteArray;

import vampire.data.Codes;
import vampire.data.Lineage;

/**
 * Manages and presents room props and data.
 */
public class RoomModel extends SimObject
{
    public function RoomModel()
    {
        registerListener(ClientContext.ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED,
            handleElementChanged);

        registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.PLAYER_LEFT,
            handlePlayerLeft);
    }

    protected function handlePlayerLeft (e :AVRGameRoomEvent) :void
    {
        var playerId :int = e.value as int;
        _lineages.remove(playerId);
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
            if (bytes != null) {
                bytes.position = 0;
                var lineage :Lineage = new Lineage();
                lineage.fromBytes(bytes);
                _lineages.put(e.index, lineage);
            }
        }
    }

    protected function handleRoomPropChanged (e :PropertyChangedEvent) :void
    {
        switch (e.name) {
            default:
            break;
        }
    }

    public function getLineage (playerId :int) :Lineage
    {
        return _lineages.get(playerId);
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    protected var _lineages :HashMap = new HashMap();


    public static const NAME :String = "RoomModel";
}
}