// $Id$

package com.threerings.graffiti.tools {

public class RectangleTool extends ShapeTool
{
    public function RectangleTool (thickness :int = 5, alpha :Number = 1.0,
        borderColor :uint = 0xFF0000, borderOn :Boolean = true,
        fillColor :uint = 0xFF0000, fillOn :Boolean = false)
    {
        super(thickness, alpha, borderColor, borderOn, fillColor, fillOn);
    }
}
}
