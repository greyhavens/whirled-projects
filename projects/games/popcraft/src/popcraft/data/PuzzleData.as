package popcraft.data {

import popcraft.*;
import popcraft.util.IntValueTable;
import popcraft.util.XmlReader;

public class PuzzleData
{
    public var useSpecialPuzzleFrame :Boolean;
    public var resources :Array = []; // Array<ResourceData>
    public var clearValues :IntValueTable;

    public function clone () :PuzzleData
    {
        var theClone :PuzzleData = new PuzzleData();

        theClone.useSpecialPuzzleFrame = useSpecialPuzzleFrame;
        for each (var resData :ResourceData in resources) {
            theClone.resources.push(resData.clone());
        }
        theClone.clearValues = clearValues.clone();

        return theClone;
    }

    public static function fromXml (xml :XML, defaults :PuzzleData = null) :PuzzleData
    {
        var useDefaults :Boolean = (defaults != null);
        var data :PuzzleData = (useDefaults ? defaults : new PuzzleData());

        data.useSpecialPuzzleFrame = XmlReader.getBooleanAttr(xml, "useSpecialPuzzleFrame",
            (useDefaults ? defaults.useSpecialPuzzleFrame : undefined));

        var clearTableXml :XML = XmlReader.getSingleChild(xml, "ClearValues",
            (useDefaults ? null : undefined));
        if (clearTableXml != null) {
            data.clearValues = IntValueTable.fromXml(clearTableXml);
        }

        // init the resource data
        for (var ii :int = data.resources.length; ii < Constants.RESOURCE_NAMES.length; ++ii) {
            data.resources.push(null);
        }

        for each (var resourceNode :XML in xml.Resource) {
            var type :int = XmlReader.getEnumAttr(resourceNode, "type", Constants.RESOURCE_NAMES);
            data.resources[type] = ResourceData.fromXml(resourceNode,
                (useDefaults ? defaults.resources[type] : null));
        }

        return data;
    }

}

}
