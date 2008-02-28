// $Id$

package com.threerings.graffiti {

import flash.display.Sprite;

import fl.skins.DefaultButtonSkins;
import fl.skins.DefaultSliderSkins;

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
        // wire up canvas notification of tool changes - must be done before the toolbox is added
        // to the stage.
        toolBox.addEventListener(ToolEvent.COLOR_PICKED, canvas.colorPicked);
        toolBox.addEventListener(ToolEvent.BRUSH_PICKED, canvas.brushPicked);
        toolBox.x = Canvas.CANVAS_WIDTH;
        addChild(toolBox);
    }

    private static function referenceSkins () :void
    {
        // make sure the skins we use in this app get included by the compiler
        DefaultSliderSkins;
    }
}
}
