package redrover.net {

import com.threerings.util.HashMap;
import com.threerings.util.StringUtil;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertySubControl;

import flash.events.EventDispatcher;
import flash.utils.Dictionary;

public class LocalPropertySubControl extends EventDispatcher
    implements PropertySubControl
{
    public function set (propName :String, value :Object, immediate :Boolean = false) :void
    {
        var oldVal :Object = _props.get(propName);
        if (value == null) {
            _props.remove(propName);
        } else {
            _props.put(propName, value);
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
        var arr :Array = _props.get(propName);
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
        var prop :Object = _props.get(propName);
        if (prop != null && !prop is Dictionary) {
            // fail if there was a property set here and it wasn't a Dictionary
            return;

        } else if (prop == null) {
            // If there was no property here, create a dictionary
            prop = new Dictionary();
            _props.put(propName, prop);
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
        return _props.get(propName);
    }

    public function getPropertyNames (prefix :String = "") :Array
    {
        var keys :Array = _props.keys();
        if (prefix != null && prefix.length > 0) {
            keys = keys.filter(
                function (key :String, index :int, arr :Array) :Boolean {
                    return StringUtil.startsWith(key, prefix);
                });
        }

        return keys;
    }

    public function getTargetId () :int
    {
        return 0;
    }

    protected var _props :HashMap = new HashMap();
}

}
