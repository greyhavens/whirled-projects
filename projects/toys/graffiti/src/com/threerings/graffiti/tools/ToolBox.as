// $Id$

package com.threerings.graffiti.tools {

import flash.display.Sprite;

import flash.events.Event;

import com.threerings.util.Log;

import com.threerings.graffiti.Canvas;

[Event(name="colorPicked", type="ToolEvent")];
[Event(name="brushPicked", type="ToolEvent")];

public class ToolBox extends Sprite 
{
    public function ToolBox (canvas :Canvas) 
    {
        _canvas = canvas;

        var palette :Palette = new Palette(this, 0xFF0000);
        addChild(palette);
        var brushTool :BrushTool = new BrushTool(this);
        addChild(brushTool);
        _tools.concat([ palette, brushTool ]);

        layout();
    }

    public function pickColor (color :int) :void
    {
        dispatchEvent(new ToolEvent(ToolEvent.COLOR_PICKED, color));
    }

    public function brushPicked (brush :Brush) :void
    {
        dispatchEvent(new ToolEvent(ToolEvent.BRUSH_PICKED, brush.clone()));
    }

    protected function layout () :void
    {
        // for now, just lay them out centered hoirzontally and stacked on top of each other
        var curY :int = 0;
        for each (var tool :Tool in _tools) {
            tool.x = (TOOLBOX_WIDTH - tool.requestedWidth) / 2;
            tool.y = curY + PADDING;
            curY += tool.requestedHeight;
        }
    }

    private static const log :Log = Log.getLog(ToolBox);

    protected static const TOOLBOX_WIDTH :int = 100;
    protected static const PADDING :int = 10;

    protected var _canvas :Canvas;
    protected var _tools :Array = [];
}
}
