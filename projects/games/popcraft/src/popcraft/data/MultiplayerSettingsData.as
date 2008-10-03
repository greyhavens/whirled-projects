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

        data.arrangeType = XmlReader.getEnumAttr(xml, "arrangeType",
            Constants.TEAM_ARRANGEMENT_NAMES);
        data.smallerTeamHandicap = XmlReader.getNumberAttr(xml, "smallerTeamHandicap");
        data.mapSettings = MapSettingsData.fromXml(XmlReader.getSingleChild(xml, "MapSettings"));

        return data;
    }
}

}
