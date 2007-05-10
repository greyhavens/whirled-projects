//
// $Id$

package {

import flash.geom.Point;

import com.threerings.util.StringUtil;

/**
 * Remix utilities to parse remixable data XML.
 */
//
// TODO: Much of this class is untested and is currently "beta" quality.
// 
public class RemixUtil
{
    public static function getPoint (name :String, data :XML) :Point
    {
        return (getResource(name, data) as Point);
    }

    public static function getArray (name :String, data :XML) :Array
    {
        return (getResource(name, data) as Array);
    }

    public static function getBoolean (name :String, data :XML) :Boolean
    {
        return (getResource(name, data) as Boolean);
    }

    public static function getResource (name :String, data :XML) :*
    {
        var datum :XML = data..data.(@name == name)[0];
        if (datum == null) {
            return undefined;
        }

        var val :XMLList = datum.@value;
        if (val.length == 0 || val[0] === undefined) {
            return undefined;
        }

        var value :String = String(val[0]);
        trace("Raw value for '" + name + "' is '" + value + "'");
        if (value == null) {
            return undefined;
        }
        var bits :Array;
        switch (String(datum.attribute("type"))) {
        case "String":
            return value;

        case "Boolean":
            return "true" == value.toLowerCase();

        case "Point":
            bits = value.split(",");
            return new Point(parseFloat(bits[0]), parseFloat(bits[1]));

        case "Array":
            return value.split(",").map(StringUtil.trim);

        case "Number":
            return parseFloat(value);

        default:
            trace("Unknown resource type: " + datum.attribute("type"));
            return value;
        }
    }
}
}
