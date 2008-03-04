// $Id$

package com.threerings.graffiti.tools {

import flash.utils.ByteArray;

public class Brush 
{
    public var thickness :int;
    public var alpha :Number;

    public function Brush (thickness :int = 5, alpha :Number = 1.0)
    {
        this.thickness = thickness;
        this.alpha = alpha;
    }

    public function clone () :Brush 
    {
        return new Brush(thickness, alpha);
    }

    public function toString () :String
    {
        return "Brush [thickness=" + thickness + ", alpha=" + alpha + "]";
    }

    public function serialize (bytes :ByteArray) :void
    {
        bytes.writeInt(thickness);
        bytes.writeInt(Math.round(alpha * 100));
    }
}
}
