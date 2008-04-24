//
// $Id$

package display {

import flash.display.Sprite;

/**
 * A simple layer that just displays every piece sprite added to it.
 */
public class PieceSpriteLayer extends Layer
{
    public function addPieceSprite (ps :PieceSprite) :void
    {
        addChild(ps);
    }

    public function clear () :void
    {
        for (var ii :int = numChildren - 1; ii >= 0; ii--) {
            removeChildAt(ii);
        }
    }
}
}
