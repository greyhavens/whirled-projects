// $Id$

package com.threerings.graffiti {

import flash.display.Sprite;

public class ToolBox extends Sprite 
{
    public function ToolBox (canvas :Canvas) 
    {
        _canvas = canvas;

        addChild(_palette = new Palette(_canvas, 0));
        _palette.x += 50;
        _palette.y += 50;
    }

    protected var _canvas :Canvas;
    protected var _palette :Palette;
}
}
