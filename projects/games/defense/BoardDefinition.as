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
        
    /** Returns logical (board) coordinates corresponding to screen coordinates (in board space) */
    public function screenToLogical (x :int, y :int) :Point
    {
        return new Point(int(x / squareWidth), int(y / squareHeight));
    }

    /** Returns screen coordinates of the center of the square with specifies logical coords */
    public function logicalToScreen (x :int, y :int) :Point
    {
        return new Point((x + 0.5) * squareWidth, (y + 0.5) * squareHeight);
    }
}
}
