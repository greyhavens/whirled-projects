// $Id$

package com.threerings.graffiti {

import flash.display.Sprite;

public class ToolBox extends Sprite 
{
    public function ToolBox (canvas :Canvas) 
    {
        _canvas = canvas;

        addChild(_palette = new Palette(this, 0xFF0000));
    }

    public function pickColor (color :int) :void
    {
        _canvas.pickColor(color);
    }

    protected var _canvas :Canvas;
    protected var _palette :Palette;
}
}
