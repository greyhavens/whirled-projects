package popcraft.data {

import popcraft.*;
import popcraft.util.XmlReader;

public class MultiplayerSettingsData
{
    public var arrangeType :int;
    public var smallerTeamHandicap :Number;
    public var mapSettings :MapSettingsData;

    public static function fromXml (xml :XML) :MultiplayerSettingsData
    {
        var data :MultiplayerSettingsData = new MultiplayerSettingsData();

        data.arrangeType = XmlReader.getAttributeAsEnum(xml, "arrangeType", Constants.MULTIPLAYER_ARRANGEMENT_NAMES);
        data.smallerTeamHandicap = XmlReader.getAttributeAsNumber(xml, "smallerTeamHandicap");
        data.mapSettings = MapSettingsData.fromXml(XmlReader.getSingleChild(xml, "MapSettings"));

        return data;
    }
}

}
