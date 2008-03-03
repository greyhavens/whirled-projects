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
        var canvas :Canvas = new Canvas(new FurniControl(this));
        addChild(canvas);
        var toolBox :ToolBox = canvas.createToolbox();
        toolBox.x = Canvas.CANVAS_WIDTH;
        addChild(toolBox);
    }

    private static function referenceSkins () :void
    {
        // make sure the skins we use in this app get included by the compiler
        DefaultButtonSkins;
        DefaultSliderSkins;
    }
}
}
