// $Id$

package com.threerings.graffiti.tools {

import flash.display.Sprite;

import flash.events.Event;

import com.threerings.util.Log;

import com.threerings.graffiti.Canvas;

[Event(name="colorPicked", type="ToolEvent")];
[Event(name="brushPicked", type="ToolEvent")];
[Event(name="backgroundColor", type="ToolEvent")];

public class ToolBox extends Sprite 
{
    public function ToolBox (canvas :Canvas) 
    {
        _canvas = canvas;

        var palette :Palette = new Palette(this, 0xFF0000);
        addChild(palette);
        _tools.push(palette);

        var brushTool :BrushTool = new BrushTool(this);
        addChild(brushTool);
        _tools.push(brushTool);

        var controls :Controls = new Controls(this);
        addChild(controls);
        _tools.push(controls);

        layout();
    }

    public function pickColor (color :uint) :void
    {
        dispatchEvent(new ToolEvent(ToolEvent.COLOR_PICKED, color));
    }

    public function brushPicked (brush :Brush) :void
    {
        dispatchEvent(new ToolEvent(ToolEvent.BRUSH_PICKED, brush.clone()));
    }

    public function setBackgroundColor (color :uint) :void
    {
        dispatchEvent(new ToolEvent(ToolEvent.BACKGROUND_COLOR, color));
    }

    protected function layout () :void
    {
        graphics.lineStyle(2, 0x005500);
        graphics.beginFill(0xFFFFFF);
        // for now, just lay them out centered hoirzontally and stacked on top of each other
        var curY :int = 0;
        for each (var tool :Tool in _tools) {
            tool.x = (TOOLBOX_WIDTH - tool.requestedWidth) / 2;
            tool.y = curY;
            curY += tool.requestedHeight;
            graphics.drawRoundRect(2, tool.y, TOOLBOX_WIDTH - 4, tool.requestedHeight, 5);
        }
        graphics.endFill();
    }

    private static const log :Log = Log.getLog(ToolBox);

    protected static const TOOLBOX_WIDTH :int = 100;

    protected var _canvas :Canvas;
    protected var _tools :Array = [];
}
}
