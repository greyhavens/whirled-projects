// $Id$

package com.threerings.graffiti.tools {

public class BrushTool extends Tool
{
    public function BrushTool (toolBox :ToolBox) 
    {
        _toolBox = toolBox;
    }

    // from Tool
    public override function get requestedWidth () :Number
    {
        return 0;
    }

    // from Tool
    public override function get requestedHeight () :Number
    {
        return 0;
    }

    protected var _toolBox :ToolBox;
}
}
