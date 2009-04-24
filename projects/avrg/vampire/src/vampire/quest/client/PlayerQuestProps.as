package vampire.quest.client {

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.ImmediatePropControl;
import com.whirled.contrib.namespc.*;
import com.whirled.net.NetConstants;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertySubControl;

import flash.events.EventDispatcher;

import vampire.quest.*;

[Event(name="PropChanged", type="vampire.quest.QuestPropEvent")]

public class PlayerQuestProps extends EventDispatcher
{
    public function PlayerQuestProps (propCtrl :PropertySubControl)
    {
        _propCtrl = new ImmediatePropControl(new NamespacePropControl(NAMESPACE, propCtrl));
        _events.registerListener(_propCtrl, PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
    }

    public function setProp (name :String, val :Object) :void
    {
        _propCtrl.set(encodeName(name), val);
    }

    public function clearProp (name :String) :void
    {
        setProp(name, null);
    }

    public function getProp (name :String) :Object
    {
        return _propCtrl.get(encodeName(name));
    }

    public function getIntProp (name :String) :int
    {
        return getProp(name) as int;
    }

    public function offsetIntProp (name :String, incr :int) :void
    {
        if (incr != 0) {
            setProp(name, getIntProp(name) + incr);
        }
    }

    public function propExists (name :String) :Boolean
    {
        return (getProp(name) != null);
    }

    public function getPropNames () :Array
    {
        return _propCtrl.getPropertyNames().map(
            function (propName :String, ...ignored) :String {
                return decodeName(propName);
            });
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        dispatchEvent(new QuestPropEvent(QuestPropEvent.PROP_CHANGED, decodeName(e.name)));
    }

    protected function encodeName (val :String) :String
    {
        return NetConstants.makePersistent(val);
    }

    protected function decodeName (val :String) :String
    {
        return NetConstants.makeTransient(val);
    }

    protected var _propCtrl :PropertySubControl;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static const NAMESPACE :String = "pqs";
}

}
