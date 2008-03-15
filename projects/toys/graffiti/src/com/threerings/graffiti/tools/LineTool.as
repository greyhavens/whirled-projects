// $Id$

package com.threerings.graffiti.tools {

public class LineTool extends Tool 
{
    public function LineTool (thickness :int = 5, alpha :Number = 1.0, color :uint = 0xFF0000) 
    {
        super(thickness, alpha, color);
    }

    public function clone () :LineTool
    {
        return new LineTool(thickness, alpha, color);
    }

    public function toString () :String
    {
        return "LineTool [thickness=" + thickness + ", alpha=" + alpha + ", color=" + color + "]";
    }
}
}
