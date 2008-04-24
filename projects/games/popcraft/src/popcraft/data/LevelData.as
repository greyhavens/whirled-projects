package popcraft.data {

import com.threerings.util.ArrayUtil;

import popcraft.*;
import popcraft.util.*;

public class LevelData
{
    public var name :String = "";
    public var introText :String = "";
    public var playerBaseHealth :int;
    public var disableDiurnalCycle :Boolean;

    public var availableUnits :Array = [];
    public var computers :Array = [];

    public function isAvailableUnit (unitType :uint) :Boolean
    {
        return ArrayUtil.contains(availableUnits, unitType);
    }

    public static function fromXml (xml :XML) :LevelData
    {
        var level :LevelData = new LevelData();

        level.name = XmlReader.getAttributeAsString(xml, "name");
        level.introText = XmlReader.getAttributeAsString(xml, "introText");
        level.playerBaseHealth = XmlReader.getAttributeAsInt(xml, "playerBaseHealth");
        level.disableDiurnalCycle = XmlReader.getAttributeAsBoolean(xml, "disableDiurnalCycle", false);

        // parse the available units
        for each (var unitData :XML in xml.AvailableUnits.Unit) {
            level.availableUnits.push(XmlReader.getAttributeAsEnum(unitData, "type", Constants.CREATURE_UNIT_NAMES));
        }

        // parse the computer players
        for each (var computerData :XML in xml.Computer) {
            level.computers.push(ComputerPlayerData.fromXml(computerData));
        }

        return level;
    }
}

}
