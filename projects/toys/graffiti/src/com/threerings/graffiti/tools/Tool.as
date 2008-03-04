// $Id$

package com.threerings.graffiti.tools {

import flash.display.Sprite;

// Abstract
public class Tool extends Sprite
{
    public function get requestedWidth () :Number 
    {
        return 0;
    }

    public function get requestedHeight () :Number
    {
        return 0;
    }

    protected static const PADDING :int = 5;
}
}
