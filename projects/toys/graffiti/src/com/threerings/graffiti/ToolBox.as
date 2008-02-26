// $Id$

package com.threerings.graffiti {

import flash.display.Sprite;

public class ToolBox extends Sprite 
{
    public function ToolBox (canvas :Canvas) 
    {
        _canvas = canvas;

        addChild(_palette = new Palette(_canvas, 0));
    }

    protected var _canvas :Canvas;
    protected var _palette :Palette;
}
}
