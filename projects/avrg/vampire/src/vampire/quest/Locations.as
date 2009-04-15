package vampire.quest {

import com.threerings.util.HashMap;
import com.threerings.util.Log;

public class Locations
{
    public static function init () :void
    {
        _inited = true;

        // create some dummy Locations
        var homeBase :LocationDesc = new LocationDesc("HomeBase", "Home Base");
        var battleground :LocationDesc = new LocationDesc("Battleground", "Battleground");
        var dragons :LocationDesc = new LocationDesc("Dragons", "Here Be Dragons");
        addLocation(homeBase);
        addLocation(battleground);
        addLocation(dragons);

        makeTwoWayConnection("HomeBase", "Battleground", 10);
        makeTwoWayConnection("Battleground", "Dragons", 10);
        makeTwoWayConnection("HomeBase", "Dragons", 30);

        // add some activities
        battleground.activities.push(new ActivityDesc(
            ActivityDesc.TYPE_CORRUPTION,
            "Whack a small monster",
            new CorruptionActivityParams(100, 1, 1, "Monster", 1)));
        battleground.activities.push(new ActivityDesc(
            ActivityDesc.TYPE_CORRUPTION,
            "Whack a LARGE monster",
            new CorruptionActivityParams(500, 1, 5, "Monster", 3)));
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

    protected static function makeTwoWayConnection (aName :String, bName :String, cost :int)
        :void
    {
        var a :LocationDesc = getLocationByName(aName);
        var b :LocationDesc = getLocationByName(bName);
        if (a == null) {
            throw new Error("Unrecognized Location [name=" + aName + "]");
        }
        if (b == null) {
            throw new Error("Unrecognized Location [name=" + bName + "]");
        }

        if (a.isConnectedTo(b) || b.isConnectedTo(a)) {
            throw new Error(
                "Locations are already connected [aName=" + aName + " bName=" + bName + "]");
        }

        a.connectedLocs.push(new LocationConnection(b, cost));
        b.connectedLocs.push(new LocationConnection(a, cost));
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
