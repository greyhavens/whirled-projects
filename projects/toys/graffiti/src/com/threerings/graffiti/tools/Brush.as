// $Id$

package com.threerings.graffiti.tools {

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
}
}
