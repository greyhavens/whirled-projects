package popcraft.sp {

import com.threerings.util.ArrayUtil;

public class LevelData
{
    public var name :String = "";
    public var introText :String = "";
    public var availableUnits :Array = [];
    public var disableDiurnalCycle :Boolean;
    public var computers :Array = [];

    public function isAvailableUnit (unitType :uint) :Boolean
    {
        return ArrayUtil.contains(availableUnits, unitType);
    }
}

}
