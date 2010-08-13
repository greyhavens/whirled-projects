//
// $Id$

package popcraft.gamedata {

import com.threerings.util.XmlUtil;

public class EndlessHumanPlayerData
{
    public var resourceHandicap :Number = 1;
    public var baseLoc :BaseLocationData;
    public var availableUnits :Array = [];
    public var availableSpells :Array = [];

    public static function fromXml (xml :XML) :EndlessHumanPlayerData
    {
        var data :EndlessHumanPlayerData = new EndlessHumanPlayerData();

        data.resourceHandicap = XmlUtil.getNumberAttr(xml, "resourceHandicap", 1);
        data.baseLoc = BaseLocationData.fromXml(XmlUtil.getSingleChild(xml, "BaseLocation"));

        // parse the available units and spells
        data.availableUnits = DataUtil.parseCreatureTypes(xml.AvailableUnits[0]);
        data.availableSpells = DataUtil.parseCastableSpellTypes(xml.AvailableSpells[0]);

        return data;
    }
}

}
