package spades.graphics {

import flash.display.DisplayObject;

/**
 * Static stuff for the spades display.
 */
public class Display
{
    public static const WIDTH :int = 700;
    public static const HEIGHT :int = 550;

    /** Move an object's center to a given position. */
    public static function move (obj :DisplayObject, pos :Position) :void
    {
        var centerx :int = WIDTH * pos.hfraction;
        var centery :int = HEIGHT * pos.vfraction;
        obj.x = centerx;
        obj.y = centery;
    }


    /** Move an object's top-left corner to a given position. */
    public static function movetl (obj :DisplayObject, pos :Position) :void
    {
        var centerx :int = WIDTH * pos.hfraction;
        var centery :int = HEIGHT * pos.vfraction;
        obj.x = centerx - obj.width / 2;
        obj.y = centery - obj.height / 2;
    }
}

}
