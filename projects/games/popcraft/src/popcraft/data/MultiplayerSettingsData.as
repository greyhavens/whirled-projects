package popcraft.data {

import com.threerings.util.XmlUtil;

import popcraft.*;

public class MultiplayerSettingsData
{
    public var arrangeType :int;
    public var smallerTeamHandicap :Number;
    public var mapSettings :MapSettingsData;

    public static function fromXml (xml :XML) :MultiplayerSettingsData
    {
        var data :MultiplayerSettingsData = new MultiplayerSettingsData();

        data.arrangeType = XmlUtil.getStringArrayAttr(xml, "arrangeType",
            Constants.TEAM_ARRANGEMENT_NAMES);
        data.smallerTeamHandicap = XmlUtil.getNumberAttr(xml, "smallerTeamHandicap");
        data.mapSettings = MapSettingsData.fromXml(XmlUtil.getSingleChild(xml, "MapSettings"));

        return data;
    }
}

}
