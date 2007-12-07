package def {

import flash.geom.Point;

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.ContentAssert;



/** Typesafe wrapper class for specifying special tiles on the board. */
public class SpecialTileDefinition
{
    /** Tiles of this type cannot be built on, but enemies can walk through them. */
    public static const TYPE_RESERVED :String = "reserved";

    /** Tiles of this type cannot be built or walked on. */
    public static const TYPE_INVALID :String = "invalid";

    
    public static const ALL_TYPES :Array = [ TYPE_RESERVED, TYPE_INVALID ];
    
    public var typeName :String;
    public var pos :Point;

    public function SpecialTileDefinition (typeName :String, x :Number, y :Number)
    {
        ContentAssert.isTrue(ArrayUtil.contains(ALL_TYPES, typeName),
                             "Invalid special tile type: '" + typeName +
                             "', expected one of: " + ALL_TYPES);
        
        this.typeName = typeName;
        this.pos = new Point(x, y);
    }

    public function toString () :String
    {
        return "Special tile [typeName=" + typeName + ", pos=" + pos + "]";
    }

  }
}
