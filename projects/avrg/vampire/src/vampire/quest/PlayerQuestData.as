package vampire.quest {

import com.threerings.util.Util;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.namespc.NamespacePropControl;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.NetConstants;
import com.whirled.net.PropertySubControl;

import flash.events.EventDispatcher;
import flash.utils.Dictionary;

public class PlayerQuestData extends EventDispatcher
{
    public function PlayerQuestData (props :PropertySubControl) :void
    {
        _props = new NamespacePropControl(NAMESPACE, props);
        _events.registerListener(_props, ElementChangedEvent.ELEMENT_CHANGED, onElementChanged);
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
    }

    public function addQuest (questId :int) :void
    {
        _props.setIn(PROP_ACTIVE_QUESTS, questId, true, false);
    }

    public function completeQuest (questId :int) :void
    {
        _props.setIn(PROP_ACTIVE_QUESTS, questId, null, false);
    }

    public function isActiveQuest (questId :int) :Boolean
    {
        var dict :Dictionary = _props.get(PROP_ACTIVE_QUESTS) as Dictionary;
        return (dict != null && dict[questId] !== undefined ? true : false);
    }

    public function get activeQuests () :Array
    {
        var quests :Dictionary = _props.get(PROP_ACTIVE_QUESTS) as Dictionary;
        return (quests != null ? Util.keys(quests) : []);
    }

    protected function onElementChanged (e :ElementChangedEvent) :void
    {
        if (e.name == PROP_ACTIVE_QUESTS) {
            var questId :int = e.key;
            var eventType :String = (e.newValue != null ? PlayerQuestEvent.QUEST_ADDED :
                PlayerQuestEvent.QUEST_COMPLETED);
            dispatchEvent(new PlayerQuestEvent(eventType, questId));
        }
    }

    protected var _props :PropertySubControl;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static const PROP_ACTIVE_QUESTS :String = NetConstants.makePersistent("ActiveQuests");
    protected static const NAMESPACE :String = "pqd";
}

}
