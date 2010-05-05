//
// $Id$

package popcraft.data {

import com.threerings.util.XmlUtil;

import popcraft.*;

public class GameVariantData
{
    public var name :String;
    public var description :String;
    public var gameDataOverride :GameData;

    public static function fromXml (xml :XML) :GameVariantData
    {
        var variant :GameVariantData = new GameVariantData();

        variant.name = XmlUtil.getStringAttr(xml, "name");
        variant.description = XmlUtil.getStringAttr(xml, "description");

        var gameDataOverrideNode :XML = XmlUtil.getSingleChild(xml, "GameDataOverride");
        variant.gameDataOverride = GameData.fromXml(gameDataOverrideNode,
            ClientCtx.defaultGameData.clone());

        return variant;
    }

}

}
