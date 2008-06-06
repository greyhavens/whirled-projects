package popcraft.data {

import popcraft.*;
import popcraft.util.XmlReader;

public class GameVariantData
{
    public var name :String;
    public var description :String;
    public var gameDataOverride :GameData;

    public static function fromXml (xml :XML) :GameVariantData
    {
        var variant :GameVariantData = new GameVariantData();

        variant.name = XmlReader.getAttributeAsString(xml, "name");
        variant.description = XmlReader.getAttributeAsString(xml, "description");

        var gameDataOverrideNode :XML = XmlReader.getSingleChild(xml, "GameDataOverride");
        variant.gameDataOverride = GameData.fromXml(gameDataOverrideNode, AppContext.defaultGameData.clone());

        return variant;
    }

}

}
