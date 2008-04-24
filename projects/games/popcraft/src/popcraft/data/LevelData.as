package popcraft.data {

import com.threerings.util.ArrayUtil;

import flash.net.URLLoader;
import flash.net.URLRequest;

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

    public static function fromXml (xmlData :XML) :LevelData
    {
        var level :LevelData = new LevelData();

        var levelNode :XML = xmlData.Level[0];

        level.name = XmlReader.getAttributeAsString(levelNode, "name");
        level.introText = XmlReader.getAttributeAsString(levelNode, "introText");
        level.playerBaseHealth = XmlReader.getAttributeAsInt(levelNode, "playerBaseHealth");
        level.disableDiurnalCycle = XmlReader.getAttributeAsBoolean(levelNode, "disableDiurnalCycle", false);

        // parse the available units
        for each (var unitData :XML in levelNode.AvailableUnits.Unit) {
            level.availableUnits.push(XmlReader.getAttributeAsEnum(unitData, "type", Constants.CREATURE_UNIT_NAMES));
        }

        // parse the computer players
        for each (var computerData :XML in levelNode.Computer) {
            level.computers.push(ComputerPlayerData.fromXml(computerData));
        }

        return level;
    }
}

}
