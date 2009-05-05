package vampire.quest.client {

import com.threerings.util.Log;
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

    public function clearUntrackedProps () :void
    {
        _propCtrl.doBatch(function () :void {
            for each (var propName :String in getPropNames()) {
                if (!isTrackedProp(propName)) {
                    log.info("Clearing untracked prop", "propName", propName);
                    clearProp(propName);
                }
            }
        });
    }

    public function isTrackedProp (name :String) :Boolean
    {
        // properties are only tracked if they begin with "#", or
        // if there's an active quest that cares about it
        if (QuestProps.isPermanent(name)) {
            return true;
        } else {
            for each (var activeQuest :QuestDesc in ClientCtx.questData.activeQuests) {
                if (activeQuest.isRelevantProp(name)) {
                    return true;
                }
            }
        }

        return false;
    }

    public function setProp (name :String, val :Object) :void
    {
        if (val == null || isTrackedProp(name)) {
            _propCtrl.set(encodeName(name), val);
        } else {
            log.info("Not updating un-tracked prop", "propName", name, "val", val);
        }
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

    protected static var log :Log = Log.getLog(PlayerQuestProps);

    protected static const NAMESPACE :String = "pqs";
}

}
