package popcraft.data {

import com.threerings.util.XmlUtil;

public class EndlessComputerPlayerData extends ComputerPlayerData
{
    public var baseHealthIncrement :Number;
    public var waveDelayScale :Number;
    public var baseLoc :BaseLocationData;

    public static function fromXml (xml :XML) :EndlessComputerPlayerData
    {
        var data :EndlessComputerPlayerData = new EndlessComputerPlayerData();

        ComputerPlayerData.fromXml(xml, data);

        data.baseHealthIncrement = XmlUtil.getNumberAttr(xml, "baseHealthIncrement");
        data.waveDelayScale = XmlUtil.getNumberAttr(xml, "waveDelayScale");
        data.baseLoc = BaseLocationData.fromXml(XmlUtil.getSingleChild(xml, "BaseLocation"));

        return data;
    }

}

}
