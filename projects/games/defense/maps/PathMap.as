package maps {

/**
 * Stores pathfinding information for a single player's critters.
 */
public class PathMap extends Map
{

    override public function init () :void
    {
        for (var xx :int = 0; xx < _width; xx++) {
            for (var yy :int = 0; yy < _height; yy++) {
                _data[xx][yy] = Infinity;
            }
        }
    }
    
}
}
