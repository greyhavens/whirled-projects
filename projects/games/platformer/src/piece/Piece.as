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

    /** The piece id. */
    public var id :int;

    /** The piece size. */
    public var height :int;
    public var width :int;

    /** The piece type. */
    public var type :String = "";

    /** The piece sprite name. */
    public var sprite :String = "";

    /** The orientation. */
    public var orient :int;

    public function Piece (defxml :XML = null, insxml :XML = null)
    {
        if (defxml != null) {
            type = defxml.@type;
            height = defxml.@height;
            width = defxml.@width;
            sprite = defxml.@sprite;
        }
        if (insxml != null) {
            if (defxml == null) {
                type = insxml.@type;
            }
            x = insxml.@x;
            y = insxml.@y;
            id = insxml.@id;
            orient = insxml.@orient;
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
        xml.@id = id;
        xml.@orient = orient;
        return xml;
    }
}
}
