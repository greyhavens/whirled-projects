// $Id$

package com.threerings.graffiti {

import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.geom.Point;

public class Palette extends Sprite
{
    protected var _small :Sprite = new Sprite();
    protected var _large :Sprite = new Sprite();

    public function Palette (board :Board, initialColour :int)
    {
        _board = board;

        buildLarge();
        buildSmall(initialColour);
        show(_small);
    }

    protected function show (s :Sprite) :void
    {
        if (this.numChildren > 0) {
            this.removeChildAt(0);
        }
        this.addChild(s);
    }

    protected function buildLarge() :void
    {
        var g :Graphics = _large.graphics;

        g.beginFill(0x000000);
        g.drawRect(0, 0, 18*TOTAL_SIZE + 1, 12*TOTAL_SIZE + 1);
        g.endFill();

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

        _large.addEventListener(MouseEvent.ROLL_OUT, function (evt :MouseEvent) :void {
            show(_small);
        });

        _large.addEventListener(MouseEvent.CLICK, function (evt :MouseEvent) :void {
            var p :Point = _large.globalToLocal(new Point(evt.stageX, evt.stageY));

            var rr :int = int(p.x / (TOTAL_SIZE*6)) + 3 * int(p.y / (TOTAL_SIZE*6));
            var gg :int = (p.x % (TOTAL_SIZE*6)) / TOTAL_SIZE;
            var bb :int = (p.y % (TOTAL_SIZE*6)) / TOTAL_SIZE;

            var colour :int = rr*0x330000 + gg * 0x003300 + bb * 0x000033;

            updateSmall(colour);
            show(_small);
            _board.pickColour(colour);
        });
    }

    protected function buildSmall (colour :int) :void
    {
        _small.addEventListener(MouseEvent.ROLL_OVER, function (evt :MouseEvent) :void {
            show(_large);
        });
        updateSmall(colour);
    }

    protected function updateSmall (colour :int) :void
    {
        var g :Graphics = _small.graphics;

        g.beginFill(colour);
        g.drawCircle(4 + SQUARE_SIZE, 4 + SQUARE_SIZE, SQUARE_SIZE);
        g.endFill();
    }

    protected function handleClick (evt :MouseEvent) :void
    {
    }

    protected var _board :Board;

    protected static const SQUARE_SIZE :int = 4;
    protected static const BORDER_WIDTH :int = 1;
    protected static const TOTAL_SIZE :int = SQUARE_SIZE + BORDER_WIDTH;
}
}
