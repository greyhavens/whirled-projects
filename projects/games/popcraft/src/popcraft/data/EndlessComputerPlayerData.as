package popcraft.data {

import popcraft.util.XmlReader;

public class EndlessComputerPlayerData extends ComputerPlayerData
{
    public var baseHealthIncrement :Number;
    public var waveDelayScale :Number;
    public var baseLoc :BaseLocationData;

    public static function fromXml (xml :XML) :EndlessComputerPlayerData
    {
        var data :EndlessComputerPlayerData = new EndlessComputerPlayerData();

        ComputerPlayerData.fromXml(xml, data);

        data.baseHealthIncrement = XmlReader.getNumberAttr(xml, "baseHealthIncrement");
        data.waveDelayScale = XmlReader.getNumberAttr(xml, "waveDelayScale");
        data.baseLoc = BaseLocationData.fromXml(XmlReader.getSingleChild(xml, "BaseLocation"));

        return data;
    }

}

}
