package {

import flash.display.DisplayObject;

/**
 * Represents a rectangular display of fixed width and height.
 * @TODO Allow the width and height to vary based on browser changes.
 * @TODO Integrate more tightly with the "main" sprite.
 */
public class Display
{
    /** Create a new display of a fixed width and height. */
    public function Display (width :int, height :int)
    {
        _width = width;
        _height = height;
    }

    /** Access the width of the display. */
    public function get width () :int
    {
        return _width;
    }

    /** Access the height of the display. */
    public function get height () :int
    {
        return _height;
    }

    /** Move an object to a given position. */
    public function move (obj :DisplayObject, pos :Position) :void
    {
        var centerx :int = _width * pos.hfraction;
        var centery :int = _height * pos.vfraction;
        obj.x = centerx - obj.width / 2;
        obj.y = centery - obj.height / 2;
    }

    /** Width of the display. */
    protected var _width :int;

    /** Height of the display */
    protected var _height :int;
}

}
