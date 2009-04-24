package vampire.quest {

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import vampire.quest.activity.*;

public class Locations
{
    public static function init () :void
    {
        if (_inited) {
            throw new Error("already inited");
        }

        _inited = true;

        // create some dummy Locations
        var homeBase :LocationDesc = new LocationDesc("HomeBase", "Home Base");
        var battleground :LocationDesc = new LocationDesc("Battleground", "Battleground");
        var dragons :LocationDesc = new LocationDesc("Dragons", "Here Be Dragons");
        addLocation(homeBase);
        addLocation(battleground);
        addLocation(dragons);
    }

    public static function getLocationList () :Array
    {
        // returns the entire set of locations
        return _locs.values();
    }

    public static function getLocation (locId :int) :LocationDesc
    {
        checkInited();
        return _locs.get(locId) as LocationDesc;
    }

    public static function getLocationByName (name :String) :LocationDesc
    {
        return getLocation(LocationDesc.getId(name));
    }

    protected static function addLocation (desc :LocationDesc) :void
    {
        checkInited();

        validate(desc, true);
        _locs.put(desc.id, desc);
    }

    protected static function checkInited () :void
    {
        if (!_inited) {
            throw new Error("Locations.init has not been called");
        }
    }

    protected static function validate (desc :LocationDesc, validateNotDuplicate :Boolean) :Boolean
    {
        if (desc == null) {
            log.error("Invalid Location (location is null)", new Error());
            return false;
        } else if (desc.name == null) {
            log.error("Invalid Location (id is null)", "desc", desc, new Error());
            return false;
        } else if (validateNotDuplicate && _locs.containsKey(desc.id)) {
            log.error("Invalid Location (id already exists)", "desc", desc, new Error());
            return false;
        }

        return true;
    }

    protected static var _inited :Boolean;
    protected static var _locs :HashMap = new HashMap(); // Map<id:int, loc:LocationDesc>

    protected static var log :Log = Log.getLog(Locations);
}

}
