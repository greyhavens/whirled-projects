package vampire.quest {

import com.threerings.util.HashMap;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertySubControl;

import flash.events.EventDispatcher;

/**
 * Provides a safe way of managing properties on a client, as long as the client is
 * the ONLY entity modifying those properties.
 *
 * All property values are stored locally, so the client will always be working with the latest
 * values as long as nobody else is writing to the same properties.
 */
public class SafeClientPropControl extends EventDispatcher
    implements PropertySubControl
{
    public function SafeClientPropControl (propCtrl :PropertySubControl)
    {
        _propCtrl = propCtrl;

        for each (var propName :String in _propCtrl.getPropertyNames()) {
            _localProps.put(propName, _propCtrl.get(propName));
        }
    }

    public function set (propName :String, value :Object, immediate :Boolean = false) :void
    {
        _propCtrl.set(propName, value);

        var oldVal :Object = _localProps.get(propName);
        if (value == null) {
            _localProps.remove(propName);
        } else {
            _localProps.put(propName, value);
        }

        dispatchEvent(new PropertyChangedEvent(
            PropertyChangedEvent.PROPERTY_CHANGED,
            propName,
            value,
            oldVal));
    }

    public function setAt (propName :String, index :int, value :Object, immediate :Boolean = false)
        :void
    {
        _propCtrl.setAt(propName, index, value);

        var arr :Array = _localProps.get(propName);
        if (arr == null || index >= arr.length) {
            // fail if there is no Array here, or if the index is out of bounds
            return;
        }

        var oldVal :Object = arr[index];
        arr[index] = value;

        dispatchEvent(new ElementChangedEvent(
            ElementChangedEvent.ELEMENT_CHANGED,
            propName,
            value,
            oldVal,
            index));
    }

    public function setIn (propName :String, key :int, value :Object, immediate :Boolean = false)
        :void
    {
        _propCtrl.setIn(propName, key, value);

        var prop :Object = _localProps.get(propName);
        if (prop != null && !prop is Dictionary) {
            // fail if there was a property set here and it wasn't a Dictionary
            return;

        } else if (prop == null) {
            // If there was no property here, create a dictionary
            prop = new Dictionary();
            _localProps.put(propName, prop);
        }

        var dict :Dictionary = prop as Dictionary;

        var oldVal :Object = dict[key];
        if (value == null) {
            delete dict[key];
        } else {
            dict[key] = value;
        }

        dispatchEvent(new ElementChangedEvent(
            ElementChangedEvent.ELEMENT_CHANGED,
            propName,
            value,
            oldVal,
            key));
    }

    public function get (propName :String) :Object
    {
        return _localProps.get(propName);
    }

    public function getPropertyNames (prefix :String = "") :Array
    {
        var keys :Array = _localProps.keys();
        if (prefix != null && prefix.length > 0) {
            keys = keys.filter(
                function (key :String, index :int, arr :Array) :Boolean {
                    return StringUtil.startsWith(key, prefix);
                });
        }

        return keys;
    }

    protected var _propCtrl :PropertySubControl;
    // we store a local copy of all our properties
    protected var _localProps :HashMap = new HashMap();
}

}
