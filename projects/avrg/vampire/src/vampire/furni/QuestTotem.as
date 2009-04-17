package vampire.furni {

import com.threerings.util.WeakReference;
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
            _clickCallback(_totemType, _ctrl.getMyEntityId());
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
        _clickCallback = clickCallback;
    }

    protected var _ctrl :FurniControl;
    protected var _totemType :String;
    protected var _clickCallback :Function;
}

}
