//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Shape;

import com.threerings.util.HashMap;

import piece.Piece;

/**
 * Generates a piece sprite from the supplied piece.
 */
public class PieceSpriteFactory
{
    public static function getPieceSprite (Piece piece) :PieceSprite
    {
        if (piece.type == "block") {
            var disp :DisplayObject = _spriteMap.get(piece.type) as DisplayObject;
            if (disp == null) {
                disp = blockShape();
                _spriteMap.put(piece.type, disp);
            }
            return new PieceSprite(piece, disp);
        }
    }

    public static function blockShape () :Shape
    {
        var block :Shape = new Shape();
        block.graphics.beginGradientFill(
                GradientType.LINEAR, [0xCC0000, 0x330000], [1, 1], [0x00, 0xFF],
                Matrix.createGradientBox(Metrics.TILE_SIZE, Metrics.TILE_SIZE, Math.PI / 4));
        block.graphics.lineStyle(0, 0x888888);
        block.drawRect(0, 0, Metrics.TILE_SIZE, Metrics.TILE_SIZE);
        block.endFill();
        return block;
    }

    protected static var _spriteMap :HaspMap = new HashMap();
}
}
