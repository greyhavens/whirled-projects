// $Id$

package com.threerings.graffiti.tools {

import flash.display.Graphics;
import flash.display.Sprite;

import flash.text.TextFieldAutoSize;

import fl.controls.Label;

public class FullDisplay extends Tool
{
    public function FullDisplay ()
    {   
        addChild(_meterSprite = new Sprite());
        _meterSprite.x = PADDING;
        _meterSprite.y = PADDING;

        var percentLabel :Label = new Label();
        addChild(percentLabel);
        percentLabel.autoSize = TextFieldAutoSize.CENTER;
        percentLabel.text = "SPACE";
        percentLabel.y = PADDING;
        percentLabel.x = PADDING + METER_WIDTH / 2;

        redraw();
    }

    // from Tool
    public override function get requestedWidth () :Number 
    {
        return METER_WIDTH + PADDING * 2;
    }

    // from Tool
    public override function get requestedHeight () :Number
    {
        return METER_HEIGHT + PADDING * 2;
    }

    public function set fullPercent (percent :Number) :void
    {
        _percent = percent;
        redraw();
    }

    protected function redraw () :void
    {
        var g :Graphics = _meterSprite.graphics;
        g.clear();

        var color :uint = NORMAL_COLOR;
        if (_percent > DANGER_THRESHOLD) {
            color = DANGER_COLOR;
        }
        g.beginFill(color);
        g.drawRect(0, 0, Math.round(METER_WIDTH * _percent), METER_HEIGHT);
        g.endFill();

        g.lineStyle(1, 0);
        g.drawRect(0, 0, METER_WIDTH, METER_HEIGHT);
    }

    protected static const METER_HEIGHT :int = 20;
    protected static const METER_WIDTH :int = 80;

    protected static const DANGER_THRESHOLD :Number = 0.95;
    protected static const NORMAL_COLOR :uint = 0x55FF55;
    protected static const DANGER_COLOR :uint = 0xFF5555;

    protected var _percent :Number = 0;
    protected var _meterSprite :Sprite;
}
}
