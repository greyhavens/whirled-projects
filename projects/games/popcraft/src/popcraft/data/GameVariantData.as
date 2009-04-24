package popcraft.data {

import com.whirled.contrib.XmlReader;

import popcraft.*;

public class GameVariantData
{
    public var name :String;
    public var description :String;
    public var gameDataOverride :GameData;

    public static function fromXml (xml :XML) :GameVariantData
    {
        var variant :GameVariantData = new GameVariantData();

        variant.name = XmlReader.getStringAttr(xml, "name");
        variant.description = XmlReader.getStringAttr(xml, "description");

        var gameDataOverrideNode :XML = XmlReader.getSingleChild(xml, "GameDataOverride");
        variant.gameDataOverride = GameData.fromXml(gameDataOverrideNode,
            ClientCtx.defaultGameData.clone());

        return variant;
    }

}

}
