package popcraft.data {

import popcraft.util.XmlReader;

public class EndlessComputerPlayerData extends ComputerPlayerData
{
    public var baseHealthScale :Number;
    public var waveDelayScale :Number;

    public static function fromXml (xml :XML) :EndlessComputerPlayerData
    {
        var data :EndlessComputerPlayerData = new EndlessComputerPlayerData();

        ComputerPlayerData.fromXml(xml, data);

        data.baseHealthScale = XmlReader.getNumberAttr(xml, "baseHealthScale");
        data.waveDelayScale = XmlReader.getNumberAttr(xml, "waveDelayScale");

        return data;
    }

}

}
