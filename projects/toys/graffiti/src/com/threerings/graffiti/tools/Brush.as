// $Id$

package com.threerings.graffiti.tools {

import flash.utils.ByteArray;

import com.threerings.util.HashMap;

public class Brush 
{
    public var thickness :int;
    public var alpha :Number;
    public var color :uint;

    public static function createBrushFromBytes (bytes :ByteArray, colorLUT :Array = null) :Brush
    {
        var brush :Brush = new Brush();
        brush.deserialize(bytes, colorLUT);
        return brush;
    }

    public function Brush (thickness :int = 5, alpha :Number = 1.0, color :uint = 0xFF0000)
    {
        this.thickness = thickness;
        this.alpha = alpha;
        this.color = color;
    }

    public function clone () :Brush 
    {
        return new Brush(thickness, alpha, color);
    }

    public function toString () :String
    {
        return "Brush [thickness=" + thickness + ", alpha=" + alpha + "]";
    }

    public function serialize (bytes :ByteArray, colorLUT :HashMap) :void
    {
        bytes.writeInt(thickness);
        bytes.writeInt(Math.round(alpha * 100));

        // use the colorLUT if it isn't null
        if (colorLUT != null) {
            if (colorLUT.containsKey(color)) {
                bytes.writeInt(colorLUT.get(color));
            } else {
                var colorKey :int = colorLUT.size();
                colorLUT.put(color, colorKey);
                bytes.writeInt(colorKey);
            }
        } else {
            bytes.writeUnsignedInt(color);
        }
    }

    protected function deserialize (bytes :ByteArray, colorLUT :Array = null) :void
    {
        thickness = bytes.readInt();
        alpha = bytes.readInt() / 100;

        if (colorLUT != null) {
            color = colorLUT[bytes.readInt()];
        } else {
            color = bytes.readUnsignedInt();
        }
    }
}
}
