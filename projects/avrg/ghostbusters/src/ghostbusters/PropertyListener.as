//
// $Id$

package ghostbusters {

import com.whirled.AVRGameControlEvent;

public class PropertyListener
{
    public function PropertyListener (playerPropertyUpdated :Function)
    {
        _pFun = playerPropertyUpdated;

        Game.control.state.addEventListener(AVRGameControlEvent.PROPERTY_CHANGED, propertyChanged);
    }

    protected function propertyChanged (evt :AVRGameControlEvent) :void
    {
        var ix :int = evt.name.indexOf(":");
        if (ix <= 0) {
            Game.log.debug("Couldn't find colon in property: " + evt.name);
            return;
        }

        var num :Number = parseInt(evt.name.slice(1, ix));
        if (isNaN(num)) {
            Game.log.debug("Couldn't find room/player number in property: " + evt.name);
            return;
        }

        if (evt.name.charAt(0) == 'p') {
            if (Game.control.isPlayerHere(num)) {
                _pFun(num, evt.name.slice(ix+1), evt.value);
            }
            // else silently ignore

        } else {
            Game.log.debug("Unknown event type: " + evt.name);
        }
    }

    protected var _rFun :Function;
    protected var _pFun :Function;
}
}


