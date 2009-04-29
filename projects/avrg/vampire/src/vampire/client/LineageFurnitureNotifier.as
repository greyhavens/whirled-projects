package vampire.client
{
import com.whirled.EntityControl;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.contrib.simplegame.SimObject;

import flash.utils.clearInterval;

import vampire.data.FurnitureConstants;
import vampire.data.Lineage;

public class LineageFurnitureNotifier extends SimObject
{
    public function LineageFurnitureNotifier(ctrl :AVRGameControl)
    {
        super();
        _ctrl = ctrl;
        registerListener(ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM,
            handleOurPlayerEnteredRoom);
//        _events.registerListener(ctrl.room, AVRGameRoomEvent.PLAYER_ENTERED,
//            handlePlayerEnteredRoom);
//        _timerId = setInterval(uploadOurLineageToFurnIfPresent, 5000);

    }

    override protected function destroyed () :void
    {
        super.destroyed();
        clearInterval(_timerId);
    }

    protected function handleOurPlayerEnteredRoom (e :AVRGamePlayerEvent) :void
    {
        uploadOurLineageToFurnIfPresent();
    }

//    protected function handlePlayerEnteredRoom (e :AVRGamePlayerEvent) :void
//    {
//
//    }

    protected function uploadOurLineageToFurnIfPresent () :void
    {
        var lin :Lineage = ClientContext.gameMode.lineages.getLineage(ClientContext.ourPlayerId);
        uploadLineageToFurnIfPresent(lin);
    }

    public function uploadLineageToFurnIfPresent (lin :Lineage) :void
    {
        if (lin == null) {
            return;
        }
        for each (var id :String in _ctrl.room.getEntityIds(EntityControl.TYPE_FURNI)) {
            var lineageUploadFunc :Function = _ctrl.room.getEntityProperty(
                FurnitureConstants.ENTITY_PROPERTY_UPLOAD_LINEAGE, id) as Function;
            if (lineageUploadFunc != null) {
                lineageUploadFunc(lin.toArray());
            }
        }
    }

    override public function get objectName () :String
    {
        return NAME;
    }
    public static const NAME :String = "LineageFurnNotifier";

    protected var _ctrl :AVRGameControl;
    protected var _timerId :uint;
//    protected var _events :EventHandlerManager = new EventHandlerManager();

}
}