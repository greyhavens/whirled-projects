// $Id$

package com.threerings.graffiti.tools {

import flash.text.TextFieldAutoSize;

import fl.controls.Label;

public class FullDisplay extends Tool
{
    public function FullDisplay ()
    {   
        // TODO: implement a fancy meter instead of a simple text display
        addChild(_percentLabel = new Label());
        _percentLabel.autoSize = TextFieldAutoSize.LEFT;
        _percentLabel.text = "Full: 00.0%";
        _percentLabel.y = PADDING;
    }

    // from Tool
    public override function get requestedWidth () :Number 
    {
        return METER_WIDTH;
    }

    // from Tool
    public override function get requestedHeight () :Number
    {
        return PADDING * 2 + METER_HEIGHT;
    }

    public function set fullPercent (percent :Number) :void
    {
        if (percent < 10) {
            _percentLabel.text = "Full:  " + percent.toPrecision(2) + "%";
        } else {
            _percentLabel.text = "Full: " + percent.toPrecision(3) + "%";
        }
    }

    protected static const METER_HEIGHT :int = 20;
    protected static const METER_WIDTH :int = 80;

    protected var _percentLabel :Label;
}
}
