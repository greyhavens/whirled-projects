package vampire.quest {

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.namespc.*;
import com.whirled.net.NetConstants;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertySubControl;

import flash.events.EventDispatcher;

public class PlayerQuestStats extends EventDispatcher
{
    public function PlayerQuestStats (props :PropertySubControl)
    {
        _props = new NamespacePropControl(NAMESPACE, props);
        _events.registerListener(_props, PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
    }

    public function setStat (name :String, val :Object) :void
    {
        _props.set(encodeName(name), val, true);
    }

    public function clearStat (name :String) :void
    {
        setStat(name, null);
    }

    public function getStat (name :String) :Object
    {
        return _props.get(encodeName(name));
    }

    public function getIntStat (name :String) :int
    {
        return getStat(name) as int;
    }

    public function statExists (name :String) :Boolean
    {
        return (getStat(name) != null);
    }

    public function getStatNames () :Array
    {
        return _props.getPropertyNames().map(
            function (propName :String, ...ignored) :String {
                return decodeName(propName);
            });
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        dispatchEvent(new PlayerStatEvent(PlayerStatEvent.STAT_CHANGED, decodeName(e.name)));
    }

    protected function encodeName (val :String) :String
    {
        return NetConstants.makePersistent(val);
    }

    protected function decodeName (val :String) :String
    {
        return NetConstants.makeTransient(val);
    }

    protected var _props :PropertySubControl;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static const NAMESPACE :String = "pqs";
}

}
