//
// $Id$

package piece {

import com.threerings.util.ClassUtil;

/**
 * The base class for any object that will exist in the platformer.
 */
public class Piece
{
    /** The piece coordinates. */
    public var x :int;
    public var y :int;

    /** The piece size. */
    public var height :int;
    public var width :int;

    /** The piece type. */
    public var type :String = "";

    /** The piece sprite name. */
    public var sprite :String = "";

    public function Piece (defxml :XML = null, insxml :XML = null)
    {
        if (defxml != null) {
            this.type = defxml.@type;
            this.height = defxml.@height;
            this.width = defxml.@width;
            this.sprite = defxml.@sprite;
        }
        if (insxml != null) {
            if (defxml == null) {
                this.type = insxml.@type;
            }
            this.x = insxml.@x;
            this.y = insxml.@y;
        }
    }

    /**
     * Get the XML piece definition.
     */
    public function xmlDef () :XML
    {
        var xml :XML = <piecedef/>;
        xml.@type = type;
        xml.@cname = ClassUtil.getClassName(this);
        xml.@width = width;
        xml.@height = height;
        xml.@sprite = sprite;
        return xml;
    }

    /**
     * Get the XML instance definition.
     */
    public function xmlInstance () :XML
    {
        var xml :XML = <piece/>;
        xml.@type = type;
        xml.@x = x;
        xml.@y = y;
        return xml;
    }
}
}
