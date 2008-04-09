//
// $Id$

package display {

import flash.display.Shape;
import flash.display.Sprite;

import com.threerings.util.ArrayIterator;

import board.Board;

/**
 * Displays a board.
 */
public class BoardSprite extends Sprite
{
    public function BoardSprite (board :Board)
    {
        _board = board;
    }

    public function initDisplay () :void
    {
        var masker :Shape = new Shape();
        masker.graphics.beginFill(0xFFFFFF);
        masker.graphics.drawRect(0, 0, Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT);
        masker.graphics.endFill();
        mask = masker;
        addChild(masker);

        for (var iter :ArrayIterator = _board.pieceIterator(); iter.hasNext(); ) {
            var ps :PieceSprite = iter.next() as PieceSprite;
            addChild(ps);
        }
    }

    /** The board we're visualizing. */
    protected var _board :Board;
}
}
