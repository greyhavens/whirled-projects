//
// $Id$

package popcraft.data {

import com.threerings.util.XmlUtil;

import popcraft.*;
import popcraft.util.IntValueTable;

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

        data.useSpecialPuzzleFrame = XmlUtil.getBooleanAttr(xml, "useSpecialPuzzleFrame",
            (useDefaults ? defaults.useSpecialPuzzleFrame : undefined));

        var clearTableXml :XML = XmlUtil.getSingleChild(xml, "ClearValues",
            (useDefaults ? null : undefined));
        if (clearTableXml != null) {
            data.clearValues = IntValueTable.fromXml(clearTableXml);
        }

        // init the resource data
        for (var ii :int = data.resources.length; ii < Constants.RESOURCE_NAMES.length; ++ii) {
            data.resources.push(null);
        }

        for each (var resourceNode :XML in xml.Resource) {
            var type :int = XmlUtil.getStringArrayAttr(
                resourceNode, "type", Constants.RESOURCE_NAMES);
            data.resources[type] = ResourceData.fromXml(resourceNode,
                (useDefaults ? defaults.resources[type] : null));
        }

        return data;
    }

}

}
