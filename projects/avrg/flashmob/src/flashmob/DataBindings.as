package flashmob {

import com.threerings.util.HashMap;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

public class DataBindings
    implements GameDataListener
{
    public function bindMessage (messageName :String, handler :Function,
        dataTranslator :Function = null) :void
    {
        _msgBindings.put(messageName, new DataBinding(handler, dataTranslator));
    }

    public function bindProp (propName :String, handler :Function,
        dataTranslator :Function = null) :void
    {
        _propBindings.put(propName, new DataBinding(handler, dataTranslator));
    }

    public function bindElem (propName :String, handler :Function,
        dataTranslator :Function = null) :void
    {
        _elemBindings.put(propName, new DataBinding(handler, dataTranslator));
    }

    public function unbindMessage (messageName :String) :void
    {
        _msgBindings.remove(messageName);
    }

    public function unbindProp (propName :String) :void
    {
        _propBindings.remove(propName);
    }

    public function unbindElem (propName :String) :void
    {
        _elemBindings.remove(propName);
    }

    public function processAllProperties (props :PropertyGetSubControl) :void
    {
        _propBindings.forEach(function (propName :String, binding :DataBinding) :void {
            dataChanged(binding, props.get(propName));
        });
    }

    public function processProperty (propName :String, props :PropertyGetSubControl) :void
    {
        var binding :DataBinding = _propBindings.get(propName);
        if (binding != null) {
            dataChanged(binding, props.get(propName));
        }
    }

    public function onMsgReceived (e :MessageReceivedEvent) :Boolean
    {
        var binding :DataBinding = _msgBindings.get(e.name);
        if (binding != null) {
            dataChanged(binding, e.value);
            return true;
        }

        return false;
    }

    public function onPropChanged (e :PropertyChangedEvent) :Boolean
    {
        var binding :DataBinding = _propBindings.get(e.name);
        if (binding != null) {
            dataChanged(binding, e.newValue);
            return true;
        }

        return false;
    }

    public function onElemChanged (e :ElementChangedEvent) :Boolean
    {
        var binding :DataBinding = _elemBindings.get(e.name);
        if (binding != null) {
            dataChanged(binding, e.newValue, e.key, true);
            return true;
        }

        return false;
    }

    protected function dataChanged (binding :DataBinding, value :*, key :int = 0,
        useKey :Boolean = false) :void
    {
        if (binding.dataTranslator != null) {
            value = binding.dataTranslator(value);
        }

        if (useKey) {
            if (binding.handler.length == 2) {
                binding.handler(key, value);
            } else {
                binding.handler(key);
            }

        } else {
            if (binding.handler.length == 1) {
                binding.handler(value);
            } else {
                binding.handler();
            }
        }
    }

    protected var _msgBindings :HashMap = new HashMap();
    protected var _propBindings :HashMap = new HashMap();
    protected var _elemBindings :HashMap = new HashMap();
}

}

class DataBinding
{
    public var handler :Function;
    public var dataTranslator :Function;

    public function DataBinding (handler :Function, dataTranslator :Function)
    {
        this.handler = handler;
        this.dataTranslator = dataTranslator;
    }
}
