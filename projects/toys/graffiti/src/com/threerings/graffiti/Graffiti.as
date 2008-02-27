// $Id$

package com.threerings.graffiti {

import flash.display.Sprite;

import com.whirled.FurniControl;

import com.threerings.graffiti.tools.ToolBox;
import com.threerings.graffiti.tools.ToolEvent;

[SWF(width="500", height="400")]
public class Graffiti extends Sprite
{
    public function Graffiti () 
    {
        var control :FurniControl = new FurniControl(this);
        var canvas :Canvas = Canvas.createCanvas(control);
        addChild(canvas);
        var toolBox :ToolBox = new ToolBox(canvas);
        toolBox.x = Canvas.CANVAS_WIDTH;
        addChild(toolBox);

        // wire up canvas notification of tool changes
        toolBox.addEventListener(ToolEvent.COLOR_PICKED, canvas.colorPicked);
    }
}
}
