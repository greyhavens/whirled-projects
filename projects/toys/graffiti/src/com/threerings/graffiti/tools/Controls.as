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
    }
    
    // from Tool
    public override function get requestedWidth () :Number 
    {
        // temp until this gets fleshed out some more
        return 100;
    }

    // from Tool
    public override function get requestedHeight () :Number
    {
        return PADDING * 2 + BUTTON_HEIGHT;     
    }

    protected function createBackgroundButton () :void
    {
        var background :Button = new Button(); 
        background.width = 100;
        background.label = "background";
        background.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            _toolBox.setBackgroundColor(_currentColor);
        });
        background.y = PADDING + BUTTON_HEIGHT / 2;
        addChild(background);
    }

    protected static const PADDING :int = 5;
    protected static const BUTTON_HEIGHT :int = 20;

    protected var _toolBox :ToolBox;
    protected var _currentColor :uint;
}
}
