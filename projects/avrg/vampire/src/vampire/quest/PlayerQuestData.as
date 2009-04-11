package vampire.quest {

import com.threerings.util.Util;
import com.whirled.contrib.namespc.NamespacePropControl;
import com.whirled.net.PropertySubControl;

import flash.utils.Dictionary;

public class PlayerQuestData
{
    public function PlayerQuestData (props :PropertySubControl) :void
    {
        _props = new NamespacePropControl(NAMESPACE, props);
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

    protected var _props :PropertySubControl;

    protected static const PROP_ACTIVE_QUESTS :String = "ActiveQuests";
    protected static const NAMESPACE :String = "pqd";
}

}
