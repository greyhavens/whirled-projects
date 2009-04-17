package vampire.furni {

import com.threerings.util.WeakReference;
import com.whirled.FurniControl;

import flash.display.MovieClip;
import flash.events.MouseEvent;

public class QuestTotem
{
    public function QuestTotem (ctrl :FurniControl, media :MovieClip, totemType :String)
    {
        _ctrl = ctrl;
        _ctrl.registerPropertyProvider(propertyProvider);

        _totemTypeId = totemTypeId;

        media.addEventListener(MouseEvent.CLICK, onClicked);
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

    protected function onClicked (e :MouseEvent) :void
    {
        if (_clickCallbackRef != null) {
            var callback :Function = _clickCallbackRef.get() as Function;
            if (callback != null) {
                callback(_totemType);
            }
        }
    }

    protected function setClickCallback (clickCallback :Function) :void
    {
        _clickCallbackRef = new WeakReference(clickCallback);
    }

    protected var _ctrl :FurniControl;
    protected var _totemType :String;
    protected var _clickCallbackRef :WeakReference;
}

}
