package popcraft.data {

import popcraft.util.XmlReader;

public class EndlessHumanPlayerData
{
    public var resourceHandicap :Number = 1;
    public var baseLoc :BaseLocationData;
    public var availableUnits :Array = [];
    public var availableSpells :Array = [];

    public static function fromXml (xml :XML) :EndlessHumanPlayerData
    {
        var data :EndlessHumanPlayerData = new EndlessHumanPlayerData();

        data.resourceHandicap = XmlReader.getNumberAttr(xml, "resourceHandicap", 1);
        data.baseLoc = BaseLocationData.fromXml(XmlReader.getSingleChild(xml, "BaseLocation"));

        // parse the available units and spells
        data.availableUnits = DataUtil.parseCreatureTypes(xml.AvailableUnits[0]);
        data.availableSpells = DataUtil.parseCastableSpellTypes(xml.AvailableSpells[0]);

        return data;
    }
}

}
