package popcraft.data {

import popcraft.util.XmlReader;

public class EndlessComputerPlayerData extends ComputerPlayerData
{
    public var baseHealthScale :Number;

    public static function fromXml (xml :XML) :EndlessComputerPlayerData
    {
        var data :EndlessComputerPlayerData = new EndlessComputerPlayerData();

        ComputerPlayerData.fromXml(xml, data);

        data.baseHealthScale = XmlReader.getAttributeAsNumber(xml, "baseHealthScale");

        return data;
    }

}

}
