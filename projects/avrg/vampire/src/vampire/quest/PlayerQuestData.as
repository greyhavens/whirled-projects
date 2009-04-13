package vampire.quest {

import com.threerings.util.Log;
import com.threerings.util.Util;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.namespc.NamespacePropControl;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.NetConstants;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertySubControl;

import flash.events.EventDispatcher;
import flash.utils.Dictionary;

public class PlayerQuestData extends EventDispatcher
{
    public function PlayerQuestData (props :PropertySubControl) :void
    {
        _props = new NamespacePropControl(NAMESPACE, props);
        _events.registerListener(_props, ElementChangedEvent.ELEMENT_CHANGED, onElementChanged);
        _events.registerListener(_props, PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
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
        return (dict != null && dict[questId] !== undefined);
    }

    public function get activeQuests () :Array
    {
        var quests :Dictionary = _props.get(PROP_ACTIVE_QUESTS) as Dictionary;
        return (quests != null ? Util.keys(quests) : []);
    }

    public function set curLocation (locDesc :LocationDesc) :void
    {
        _props.set(PROP_CUR_LOC, locDesc.id);
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
        _props.setIn(PROP_AVAIL_LOCS, loc.id, true, false);
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
        }
    }

    protected function onElementChanged (e :ElementChangedEvent) :void
    {
        if (e.name == PROP_ACTIVE_QUESTS) {
            var questId :int = e.key;
            var eventType :String = (e.newValue != null ? PlayerQuestEvent.QUEST_ADDED :
                PlayerQuestEvent.QUEST_COMPLETED);
            dispatchEvent(new PlayerQuestEvent(eventType, questId));

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

    protected static const PROP_ACTIVE_QUESTS :String = NetConstants.makePersistent("ActiveQuests");
    protected static const PROP_AVAIL_LOCS :String = NetConstants.makePersistent("AvailLocs");
    protected static const PROP_CUR_LOC :String = NetConstants.makePersistent("CurLoc");
    protected static const NAMESPACE :String = "pqd";

    protected static var log :Log = Log.getLog(PlayerQuestData);
}

}
