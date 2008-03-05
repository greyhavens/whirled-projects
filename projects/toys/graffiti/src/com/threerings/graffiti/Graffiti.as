// $Id$

package com.threerings.graffiti {

import flash.display.Sprite;
import flash.display.Graphics;

import flash.events.MouseEvent;

import flash.text.TextField;

import fl.skins.DefaultButtonSkins;
import fl.skins.DefaultSliderSkins;

import com.threerings.util.Log;

import com.whirled.FurniControl;

import com.threerings.graffiti.tools.ToolBox;

[SWF(width="500", height="400")]
public class Graffiti extends Sprite
{
    public function Graffiti () 
    {
        var control :FurniControl = new FurniControl(this);
        var canvas :Canvas = new Canvas(control);
        addChild(canvas);

        // crazy awesome temp programmer (and programmatic!) art button.
        var editBtn :Sprite = new Sprite();
        var g :Graphics = editBtn.graphics;
        g.lineStyle(2, 0);
        g.beginFill(0xBBBBFF);
        g.drawRect(0, 0, 40, 20);
        g.endFill();
        var label :TextField = new TextField();
        label.text = "EDIT";
        label.x = 5;
        label.y = -3;
        label.selectable = false;
        label.mouseEnabled = false;
        editBtn.addChild(label);
        editBtn.x = Canvas.CANVAS_WIDTH + 10;
        editBtn.y = 10;
        editBtn.buttonMode = true;
        editBtn.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            displayPopup(control);
        });
        addChild(editBtn);
    }

    protected function displayPopup (control :FurniControl) :void
    {
        var popup :Sprite = new Sprite();
        var canvas :Canvas = new Canvas(control);
        popup.addChild(canvas);
        canvas.toolbox.x = Canvas.CANVAS_WIDTH;
        popup.addChild(canvas.toolbox);
        control.showPopup("Editing Graffiti...", popup, 
            Canvas.CANVAS_WIDTH + ToolBox.TOOLBOX_WIDTH, Canvas.CANVAS_HEIGHT, 0, 0);
    }

    private static function referenceSkins () :void
    {
        // make sure the skins we use in this app get included by the compiler
        DefaultButtonSkins;
        DefaultSliderSkins;
    }

    private static const log :Log = Log.getLog(Graffiti);
}
}
