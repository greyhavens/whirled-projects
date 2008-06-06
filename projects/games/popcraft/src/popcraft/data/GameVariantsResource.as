package popcraft.data {

import com.whirled.contrib.simplegame.resource.XmlResource;

public class GameVariantsResource extends XmlResource
{
    public function GameVariantsResource (resourceName :String, loadParams :Object)
    {
        super(resourceName, loadParams, objectGenerator);
    }

    public function get variants () :Array
    {
        return super.generatedObject;
    }

    protected static function objectGenerator (xml :XML) :Array
    {
        var variants :Array = [];
        for each (var variantNode :XML in xml.Variant) {
            variants.push(GameVariantData.fromXml(variantNode));
        }

        return variants;
    }

}

}
