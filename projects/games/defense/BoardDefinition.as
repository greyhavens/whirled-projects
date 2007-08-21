package {

import flash.geom.Point;

public class BoardDefinition
{
    public var width :int = 10;
    public var height :int = 10;

    public var squareWidth :int = 20;
    public var squareHeight :int = 20;

    public var pixelWidth :int = width * squareWidth;
    public var pixelHeight :int = height * squareHeight;
        
    /** Converts screen coordinates (relative to the upper left corner of the board) to 
     *  logical coordinates in board space. */
    public function screenToLogicalPosition (x :int, y :int) :Point
    {
        return new Point(int(Math.floor(x / squareWidth)), int(Math.floor(y / squareHeight)));
    }

    /** Converts board coordinates to screen coordinates. */
    public function logicalToScreenPosition (x :int, y :int) :Point
    {
        return new Point(x * squareWidth, y * squareHeight);
    }
}
}
