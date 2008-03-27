//
// $Id$

package ghostbusters {

import com.threerings.util.HashSet;
import com.whirled.AVRGameControlEvent;

public class PerPlayerProperties
{
    public function PerPlayerProperties (playerPropertyUpdated :Function = null)
    {
        _pFun = playerPropertyUpdated;
        if (_pFun != null) {
            Game.control.state.addEventListener(
                AVRGameControlEvent.PROPERTY_CHANGED, propertyChanged);
            Game.control.state.addEventListener(
                AVRGameControlEvent.ROOM_PROPERTY_CHANGED, propertyChanged);
        }
    }

    public function getProperty (playerId :int, property :String) :Object
    {
        return Game.control.state.getProperty("p" + playerId + ":" + property);
    }

    public function setProperty (playerId :int, property :String, value :Object) :void
    {
        Game.control.state.setProperty("p" + playerId + ":" + property, value, false);
    }

    public function getRoomProperty (playerId :int, property :String) :Object
    {
        return Game.control.state.getRoomProperty("p" + playerId + ":" + property);
    }

    public function setRoomProperty (playerId :int, property :String, value :Object) :void
    {
        Game.control.state.setRoomProperty("p" + playerId + ":" + property, value);
    }

    public function deleteRoomProperties (predicate :Function) :void
    {
        var set :HashSet = new HashSet();
        var props :Object = Game.control.state.getRoomProperties();
        for (var key :String in props) {
            var slice :Array = parseProperty(key);
            if (slice != null && predicate(slice[0], slice[1], props[key])) {
                Game.control.state.setRoomProperty(key, null);
            }
        }
    }

    protected function propertyChanged (evt :AVRGameControlEvent) :void
    {
        var slice :Array = parseProperty(evt.name);
        if (slice != null) {
            _pFun(slice[0], slice[1], evt.value);
        }
    }

    protected function parseProperty (prop :String) :Array
    {
        if (prop.charAt(0) != 'p') {
            return null;
        }

        var ix :int = prop.indexOf(":");
        if (ix <= 0) {
            return null;
        }

        var num :Number = parseInt(prop.slice(1, ix));
        if (isNaN(num)) {
            return null;
        }

        return [ int(num), prop.slice(ix+1) ];
    }

    protected var _rFun :Function;
    protected var _pFun :Function;
}
}


