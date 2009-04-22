package vampire.furni {

import com.threerings.util.Log;
import com.whirled.FurniControl;

import flash.display.MovieClip;
import flash.system.ApplicationDomain;

public class QuestTotem
{
    public function QuestTotem (media :MovieClip, ctrl :FurniControl, totemType :String)
    {
        _media = media;
        _ctrl = ctrl;
        _ctrl.registerPropertyProvider(propertyProvider);

        _totemType = totemType;
    }

    public function showActivityPanel () :void
    {
        if (_clickCallback != null) {
            log.info("showActivityPanel");
            showNotInGamePanel(false);
            _clickCallback(_totemType, _ctrl.getMyEntityId());
        } else {
            log.info("Not connected to the game; no activity panel will show.");
            showNotInGamePanel(true);
        }
    }

    protected function showNotInGamePanel (show :Boolean) :void
    {
        if (show && _notInGamePanel == null) {
            _notInGamePanel = instantiateMovieClip("not_in_game");
            if (_notInGamePanel != null) {
                _media.addChild(_notInGamePanel);
            }

        } else if (!show && _notInGamePanel != null) {
            _notInGamePanel.parent.removeChild(_notInGamePanel);
            _notInGamePanel = null;
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

    protected function instantiateMovieClip (name :String) :MovieClip
    {
        var theClass :Class = getClass(name);
        return (theClass != null ? new theClass() as MovieClip : null);
    }

    protected function getClass (name :String) :Class
    {
        var curDomain :ApplicationDomain = ApplicationDomain.currentDomain;
        return (curDomain.hasDefinition(name) ? curDomain.getDefinition(name) as Class : null);
    }

    protected var _media :MovieClip;
    protected var _ctrl :FurniControl;
    protected var _totemType :String;
    protected var _clickCallback :Function;
    protected var _notInGamePanel :MovieClip;

    protected static var log :Log = Log.getLog(QuestTotem);
}

}
