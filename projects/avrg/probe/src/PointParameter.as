package {

import flash.geom.Point;
import com.threerings.util.StringUtil;

public class PointParameter extends Parameter
{
    public function PointParameter(name :String, flags :uint=0)
    {
        super(name, Point, flags);
    }

    override public function parse (input :String) :Object
    {
        var comma :int = input.indexOf(",");
        if (comma < 1 || comma != input.lastIndexOf(",")) {
            throw new Error("Expected two number separated by one comma");
        }
        var x :Number = StringUtil.parseNumber(trim(input.substr(0, comma)));
        var y :Number = StringUtil.parseNumber(trim(input.substr(comma + 1)));
        return new Point(x, y);
    }
}

}
