//
// $Id$

package editor {

import display.PieceSprite;
import display.PieceSpriteLayer;

public class EditorPieceSpriteLayer extends PieceSpriteLayer
{
    public override function addPieceSprite (ps :PieceSprite) :void
    {
        super.addPieceSprite(ps);
        _esprites.push(ps);
    }

    public function forEachPiece (func :Function) :void
    {
        _esprites.forEach(func);
    }

    protected var _esprites :Array = new Array();
}
}
