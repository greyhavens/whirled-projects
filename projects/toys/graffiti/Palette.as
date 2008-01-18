//
// $Id$

package {

import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.geom.Point;

public class Palette extends Sprite
{
    public function Palette (board :Board)
    {
        _board = board;
        this.opaqueBackground = 0x000000;
        var g :Graphics = this.graphics;

        for (var rr :int = 0; rr < 6; rr ++) {
            var rX :int = TOTAL_SIZE*6 * int(rr % 3);
            var rY :int = TOTAL_SIZE*6 * int(rr / 3);

            for (var gg :int = 0; gg < 6; gg ++) {
                var gX :int = rX + BORDER_WIDTH*(gg+1) + SQUARE_SIZE*gg;

                for (var bb :int = 0; bb < 6; bb ++) {
                    var colour :uint = rr*0x330000 + gg * 0x003300 + bb * 0x000033;
                    var bY :int = rY + BORDER_WIDTH*(bb+1) + SQUARE_SIZE*bb;

                    g.beginFill(colour);
                    g.drawRect(gX, bY, SQUARE_SIZE, SQUARE_SIZE);
                    g.endFill();
                }
            }
        }

        this.addEventListener(MouseEvent.CLICK, handleClick);
    }

    protected function handleClick (evt :MouseEvent) :void
    {
        var p :Point = this.globalToLocal(new Point(evt.stageX, evt.stageY));

        var rr :int = int(p.x % (TOTAL_SIZE*6)) + 3 * int(p.y / (TOTAL_SIZE*6));
        var gg :int = (p.x % (TOTAL_SIZE*6)) / TOTAL_SIZE;
        var bb :int = (p.y % (TOTAL_SIZE*6)) / TOTAL_SIZE;

        _board.pickColour(rr*0x330000 + gg * 0x003300 + bb * 0x000033);
    }

    protected var _board :Board;

    protected static const SQUARE_SIZE :int = 4;
    protected static const BORDER_WIDTH :int = 1;
    protected static const TOTAL_SIZE :int = SQUARE_SIZE + BORDER_WIDTH;
}
}
