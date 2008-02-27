// $Id$

package com.threerings.graffiti.tools {

import flash.events.Event;

public class BrushTool extends Tool
{
    public function BrushTool (toolBox :ToolBox) 
    {
        _toolBox = toolBox;
        _toolBox.addEventListener(ToolEvent.COLOR_PICKED, colorPicked);

        _brush = new Brush;

        buildBrushDisplay();
        buildSliders();

        addEventListener(Event.ADDED_TO_STAGE, function (event :Event) :void {
            _toolBox.brushPicked(_brush);
        });
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

    protected function colorPicked (event :ToolEvent) :void
    {
        _color = event.value as uint;
    }

    protected function buildBrushDisplay () :void
    {
    }

    protected function buildSliders () :void
    {
    }

    protected var _toolBox :ToolBox;
    protected var _brush :Brush;
    protected var _color :uint = 0xFFFFFF;
}
}
