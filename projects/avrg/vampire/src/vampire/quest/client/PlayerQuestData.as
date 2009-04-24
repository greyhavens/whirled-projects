package vampire.quest.client {

import com.threerings.util.Log;
import com.threerings.util.Util;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.ImmediatePropControl;
import com.whirled.contrib.namespc.NamespacePropControl;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.NetConstants;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertySubControl;

import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import vampire.quest.*;

[Event(name="QuestAdded", type="vampire.quest.PlayerQuestEvent")]
[Event(name="QuestCompleted", type="vampire.quest.PlayerQuestEvent")]
[Event(name="LocationAdded", type="vampire.quest.PlayerLocationEvent")]
[Event(name="MovedToLocation", type="vampire.quest.PlayerLocationEvent")]
[Event(name="QuestJuiceChanged", type="vampire.quest.PlayerJuiceEvent")]

public class PlayerQuestData extends EventDispatcher
{
    public static const STATUS_NOT_ADDED :int = 0;
    public static const STATUS_ACTIVE :int = 1;
    public static const STATUS_COMPLETE :int = 2;

    public function PlayerQuestData (props :PropertySubControl) :void
    {
        _props = new ImmediatePropControl(new NamespacePropControl(NAMESPACE, props));
        _events.registerListener(_props, ElementChangedEvent.ELEMENT_CHANGED, onElementChanged);
        _events.registerListener(_props, PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
    }

    public function get questJuice () :int
    {
        return _props.get(PROP_QUEST_JUICE) as int;
    }

    public function set questJuice (val :int) :void
    {
        _props.set(PROP_QUEST_JUICE, val);
    }

    public function addQuest (questId :int) :void
    {
        _props.setIn(PROP_QUESTS, questId, STATUS_ACTIVE);
    }

    public function completeQuest (questId :int) :void
    {
        _props.setIn(PROP_QUESTS, questId, STATUS_COMPLETE);
    }

    public function debugClearQuest (questId :int) :void
    {
        // we only do this for debug purposes, never in the normal course of a game
        _props.setIn(PROP_QUESTS, questId, null);
    }

    public function getQuestStatus (questId :int) :int
    {
        var dict :Dictionary = _props.get(PROP_QUESTS) as Dictionary;
        // if the questId isn't in the dictionary, dict[questId] will be undefined, and
        // int(undefined) == 0 == STATUS_NOT_ADDED, so returning dict[questId] is safe here
        return (dict != null ? dict[questId] : STATUS_NOT_ADDED);
    }

    public function get activeAndCompleteQuestIds () :Array
    {
        var quests :Dictionary = _props.get(PROP_QUESTS) as Dictionary;
        return (quests != null ? Util.keys(quests) : []);
    }

    public function get activeQuestIds () :Array
    {
        return this.activeAndCompleteQuestIds.filter(
            function (questId :int, ...ignored) :Boolean {
                return (getQuestStatus(questId) == STATUS_ACTIVE);
        });
    }

    public function get activeQuests () :Array
    {
        return this.activeQuestIds.map(
            function (questId :int, ...ignored) :QuestDesc {
                return Quests.getQuest(questId);
            });
    }

    public function set curLocation (locDesc :LocationDesc) :void
    {
        _props.set(PROP_CUR_LOC, locDesc.id, true);
    }

    public function get curLocation () :LocationDesc
    {
        var prop :Object = _props.get(PROP_CUR_LOC);
        if (prop is int) {
            return Locations.getLocation(prop as int);
        } else {
            return null;
        }
    }

    public function addAvailableLocation (loc :LocationDesc) :void
    {
        _props.setIn(PROP_AVAIL_LOCS, loc.id, true);
    }

    public function get availableLocations () :Array
    {
        var dict :Dictionary = _props.get(PROP_AVAIL_LOCS) as Dictionary;
        if (dict != null) {
            return Util.keys(dict).map(
                function (locId :int, ...ignored) :LocationDesc {
                    return Locations.getLocation(locId);
                });
        } else {
            return [];
        }
    }

    public function isAvailableLocation (loc :LocationDesc) :Boolean
    {
        var dict :Dictionary = _props.get(PROP_AVAIL_LOCS) as Dictionary;
        return (dict != null && dict[loc.id] !== undefined);
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == PROP_CUR_LOC) {
            if (e.newValue == null) {
                log.warning("Player moved to a null Location");
            } else {
                var locId :int = e.newValue as int;
                var loc :LocationDesc = Locations.getLocation(locId);
                if (e.newValue == null || loc == null) {
                    log.warning("Player moved to an unrecognized location", "id", locId);
                } else {
                    dispatchEvent(
                        new PlayerLocationEvent(PlayerLocationEvent.MOVED_TO_LOCATION, loc));
                }
            }

        } else if (e.name == PROP_QUEST_JUICE) {
            if (e.newValue == null) {
                log.warning("Player quest juice is null");
            } else {
                var juice :int = e.newValue as int;
                dispatchEvent(new PlayerJuiceEvent(PlayerJuiceEvent.QUEST_JUICE_CHANGED, juice));
            }
        }
    }

    protected function onElementChanged (e :ElementChangedEvent) :void
    {
        if (e.name == PROP_QUESTS) {
            var questId :int = e.key;
            var quest :QuestDesc = Quests.getQuest(questId);
            if (quest == null) {
                log.warning("Unrecognized questId", "id", questId);
                return;
            }

            var eventType :String;
            if (e.newValue == STATUS_ACTIVE) {
                eventType = PlayerQuestEvent.QUEST_ADDED;
            } else if (e.newValue == STATUS_COMPLETE) {
                eventType = PlayerQuestEvent.QUEST_COMPLETED;
            } else {
                log.warning("Unrecognized quest status", "quest", quest, "status", e.newValue);
                return;
            }

            dispatchEvent(new PlayerQuestEvent(eventType, quest));

        } else if (e.name == PROP_AVAIL_LOCS) {
            var locId :int = e.key;
            var loc :LocationDesc = Locations.getLocation(locId);
            if (e.newValue == null) {
                log.warning("An available location was removed", "id", locId, "loc", loc);
            } else if (loc == null) {
                log.warning("An unrecognized location was added", "id", locId);
            } else {
                dispatchEvent(new PlayerLocationEvent(PlayerLocationEvent.LOCATION_ADDED, loc));
            }
        }
    }

    protected var _props :PropertySubControl;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static const PROP_QUESTS :String = NetConstants.makePersistent("Quests");
    protected static const PROP_AVAIL_LOCS :String = NetConstants.makePersistent("AvailLocs");
    protected static const PROP_CUR_LOC :String = NetConstants.makePersistent("CurLoc");
    protected static const PROP_QUEST_JUICE :String = NetConstants.makePersistent("QuestJuice");

    protected static const NAMESPACE :String = "pqd";

    protected static var log :Log = Log.getLog(PlayerQuestData);
}

}
