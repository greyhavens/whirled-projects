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

    public function addQuest (questId :String) :void
    {
        _props.setIn(PROP_ACTIVE_QUESTS, QuestDesc.hashForId(questId), true, false);
    }

    public function completeQuest (questId :String) :void
    {
        _props.setIn(PROP_ACTIVE_QUESTS, QuestDesc.hashForId(questId), null, false);
    }

    public function isActiveQuest (questId :String) :Boolean
    {
        var dict :Dictionary = _props.get(PROP_ACTIVE_QUESTS) as Dictionary;
        return (dict != null && dict[QuestDesc.hashForId(questId)] !== undefined ? true : false);
    }

    public function get activeQuestIds () :Array
    {
        var quests :Dictionary = _props.get(PROP_ACTIVE_QUESTS) as Dictionary;
        return (quests != null ? Util.keys(quests) : []);
    }

    protected function onElementChanged (e :ElementChangedEvent) :void
    {
        if (e.name == PROP_ACTIVE_QUESTS) {
            var questHash :int = e.key;
            var eventType :String = (e.newValue != null ? PlayerQuestEvent.QUEST_ADDED :
                PlayerQuestEvent.QUEST_COMPLETED);
            throw new PlayerQuestEvent(eventType, questHash);
        }
    }

    protected var _props :PropertySubControl;
    protected var _events :EventHandlerManager;

    protected static const PROP_ACTIVE_QUESTS :String = NetConstants.makePersistent("ActiveQuests");
    protected static const NAMESPACE :String = "pqd";
}

}
