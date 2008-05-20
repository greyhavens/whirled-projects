package popcraft.data {

import popcraft.util.*;

public class ResourceMultiplierData
{
    public var value :Number = 0;
    public var rarity :Number = 0;

    public function clone () :ResourceMultiplierData
    {
        var theClone :ResourceMultiplierData = new ResourceMultiplierData();
        theClone.value = value;
        theClone.rarity = rarity;

        return theClone;
    }

    public static function fromXml (xml :XML, inheritFrom :ResourceMultiplierData = null) :ResourceMultiplierData
    {
        var useDefaults :Boolean = (null != inheritFrom);

        var resourceMultiplier :ResourceMultiplierData = (useDefaults ? inheritFrom : new ResourceMultiplierData());

        resourceMultiplier.value = XmlReader.getAttributeAsNumber(xml, "value", (useDefaults ? inheritFrom.value : undefined));
        resourceMultiplier.rarity = XmlReader.getAttributeAsNumber(xml, "rarity", (useDefaults ? inheritFrom.rarity : undefined));

        return resourceMultiplier;
    }
}

}
