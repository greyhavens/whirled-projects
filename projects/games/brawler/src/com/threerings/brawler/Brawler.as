package com.threerings.brawler {

import flash.display.Sprite;

/**
 * The Brawler entry point.
 */
[SWF(width="800", height="500", frameRate="30")]
public class Brawler extends Sprite
{
    /** The width of the display. */
    public static const WIDTH :Number = 700;

    /** The height of the display. */
    public static const HEIGHT :Number = 500;

    public function Brawler ()
    {
        // create the controller (it will create the view)
        var ctrl :BrawlerController = new BrawlerController(this);

        // add the view
        addChild(ctrl.view);
    }
}
}
