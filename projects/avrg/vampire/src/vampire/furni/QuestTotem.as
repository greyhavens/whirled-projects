package vampire.furni {

import com.threerings.util.Log;
import com.whirled.FurniControl;

public class QuestTotem
{
    public function QuestTotem (ctrl :FurniControl, totemType :String)
    {
        _ctrl = ctrl;
        _ctrl.registerPropertyProvider(propertyProvider);

        _totemType = totemType;
    }

    public function showActivityPanel () :void
    {
        if (_clickCallback != null) {
            log.info("showActivityPanel");
            _clickCallback(_totemType, _ctrl.getMyEntityId());
        } else {
            log.info("Not connected to the game; no activity panel will show.");
        }
    }

    protected function propertyProvider (key :String) :Object
    {
        switch (key) {
        case FurniConstants.ENTITY_PROP_SET_CLICK_CALLBACK:
            return setClickCallback as Object;

        default:
            return null;
        }
    }

    protected function setClickCallback (clickCallback :Function) :void
    {
        log.info((clickCallback != null ? "connected to game" : "disconnected from game"),
            "entityId", _ctrl.getMyEntityId());

        _clickCallback = clickCallback;
    }

    protected var _ctrl :FurniControl;
    protected var _totemType :String;
    protected var _clickCallback :Function;

    protected static var log :Log = Log.getLog(QuestTotem);
}

}
