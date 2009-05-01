package vampire.client
{
import com.whirled.EntityControl;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.objects.IShutdown;

import flash.utils.clearInterval;

import vampire.client.events.LineageUpdatedEvent;
import vampire.data.Lineage;
import vampire.furni.FurniConstants;

public class LineageFurnitureNotifier
    implements IShutdown
{
    public function LineageFurnitureNotifier(ctrl :AVRGameControl, lineages :LineagesClient)
    {
        super();
        _ctrl = ctrl;
        _lineages = lineages;
        _events.registerListener(ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM,
            handleOurPlayerEnteredRoom);
        _events.registerListener(lineages, LineageUpdatedEvent.LINEAGE_UPDATED,
            handleLineageUpdated);
        uploadLineagesToFurnIfPresent();

        _events.registerListener(_ctrl.room, AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignal);
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
        clearInterval(_timerId);
    }

    protected function handleSignal (e :AVRGameRoomEvent) :void
    {
        if (e.name == FurniConstants.SIGNAL_SEND_FURN_LINEAGES) {
            uploadLineagesToFurnIfPresent();
        }
    }

    protected function handleLineageUpdated (e :LineageUpdatedEvent) :void
    {
        uploadLineageToFurnIfPresent(e.lineage);
    }

//    override protected function destroyed () :void
//    {
//        super.destroyed();
//        clearInterval(_timerId);
//    }

    protected function handleOurPlayerEnteredRoom (e :AVRGamePlayerEvent) :void
    {
        uploadLineagesToFurnIfPresent();
    }

    protected function uploadLineagesToFurnIfPresent () :void
    {
        for each (var playerId :int in _ctrl.room.getPlayerIds()) {
            var lin :Lineage = _lineages.getLineage(playerId);
            uploadLineageToFurnIfPresent(lin);
        }
    }

    public function uploadLineageToFurnIfPresent (lin :Lineage) :void
    {
        if (lin == null) {
            return;
        }
        for each (var id :String in _ctrl.room.getEntityIds(EntityControl.TYPE_FURNI)) {
            var lineageUploadFunc :Function = _ctrl.room.getEntityProperty(
                FurniConstants.ENTITY_PROP_UPLOAD_LINEAGE, id) as Function;
            if (lineageUploadFunc != null) {
                lineageUploadFunc(lin.toArray());
            }
        }
    }

//    override public function get objectName () :String
//    {
//        return NAME;
//    }
//    public static const NAME :String = "LineageFurnNotifier";

    protected var _ctrl :AVRGameControl;
    protected var _lineages :LineagesClient;
    protected var _timerId :uint;
    protected var _events :EventHandlerManager = new EventHandlerManager();

}
}