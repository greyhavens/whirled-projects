// $Id$

package com.threerings.graffiti.tools {

import flash.events.MouseEvent;

import fl.controls.Button;

public class Controls extends Tool 
{
    public function Controls (toolBox :ToolBox) 
    {
        _toolBox = toolBox;
        _toolBox.addEventListener(ToolEvent.COLOR_PICKED, function (event :ToolEvent) :void {
            _currentColor = event.value as uint;
        });

        createBackgroundButton();
        createEraseButton();
    }
    
    // from Tool
    public override function get requestedWidth () :Number 
    {
        return BUTTON_WIDTH;
    }

    // from Tool
    public override function get requestedHeight () :Number
    {
        return PADDING * 3 + BUTTON_HEIGHT * 2;
    }

    protected function createBackgroundButton () :void
    {
        var background :Button = new Button(); 
        background.setSize(BUTTON_WIDTH, BUTTON_HEIGHT);
        background.label = "background";
        background.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            _toolBox.setBackgroundColor(_currentColor);
        });
        background.y = PADDING;
        addChild(background);
    }

    protected function createEraseButton () :void
    {
        var erase :Button = new Button();
        erase.setSize(BUTTON_WIDTH, BUTTON_HEIGHT);
        erase.label = "erase";
        erase.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            _toolBox.clearCanvas();
        });
        erase.y = PADDING * 2 + BUTTON_HEIGHT;
        addChild(erase);
    }

    protected static const BUTTON_WIDTH :int = 80;
    protected static const BUTTON_HEIGHT :int = 20;

    protected var _toolBox :ToolBox;
    protected var _currentColor :uint;
}
}
