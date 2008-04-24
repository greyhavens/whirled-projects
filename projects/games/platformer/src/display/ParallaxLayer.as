//
// $Id$

package display {

public class ParallaxLayer extends Layer
{
    public function ParallaxLayer (sX :int = 1, sY :int = 1)
    {
        _scaleX = sX;
        _scaleY = sY;
    }

    public override function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        super.update(nX/_scaleX, nY/_scaleY);
    }

    /** The ratio of movement from the main layer to this parallax layer. */
    protected var _scaleX :int;
    protected var _scaleY :int;
}
}
