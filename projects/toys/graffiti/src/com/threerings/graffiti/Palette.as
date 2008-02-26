// $Id$

package com.threerings.graffiti {

import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.geom.Point;

import com.threerings.util.Log;

public class Palette extends Sprite
{
    public function Palette (canvas :Canvas, initialColour :int)
    {
        _canvas = canvas;

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

        // start by drawing a color wheel...
        for (var ii :int = 0; ii < 360; ii++) {
            g.lineStyle(1, colorForAngle(ii));
            g.moveTo(0, 0);
            var end :Point = Point.polar(50, ii * Math.PI / 180);
            g.lineTo(-end.x, end.y);
        }

        _large.addEventListener(MouseEvent.ROLL_OUT, function (evt :MouseEvent) :void {
            show(_small);
        });

        _large.addEventListener(MouseEvent.CLICK, function (evt :MouseEvent) :void {
            var p :Point = _large.globalToLocal(new Point(evt.stageX, evt.stageY));
            var angle :int = Math.round(Math.atan2(p.y, -p.x) * 180 / Math.PI);
            var color :int = colorForAngle(angle);

            updateSmall(color);
            show(_small);
            _canvas.pickColor(color);
        });
    }

    protected function colorForAngle (angle :int) :int
    {
        var color :int = 0;
        var shifts :Array = [0, -120, -240];
        for (var colors :int = 0; colors < 3; colors++) {
            color = color << 8;
            var adjustedAngle :int = ((angle + shifts[colors] + 360) % 360) - 180;
            if (adjustedAngle > -60 && adjustedAngle < 60) {
                // 120 degrees surrounding the base area for this color, paint the full color value
                color += 0xFF;
            } else if (adjustedAngle > -120 && adjustedAngle < 120) {
                // for the area -60 - -120 and 60 - 120 degrees away from the base area, gradually
                // reduce the value for this color 
                var percent :Number = 1 - (Math.abs(adjustedAngle) - 60) / 60;
                color += percent * 0xFF;
            }
        }
        return color;
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

    private static const log :Log = Log.getLog(Palette);

    protected static const SQUARE_SIZE :int = 4;
    protected static const BORDER_WIDTH :int = 1;
    protected static const TOTAL_SIZE :int = SQUARE_SIZE + BORDER_WIDTH;

    protected var _canvas :Canvas;

    protected var _small :Sprite = new Sprite();
    protected var _large :Sprite = new Sprite();
}
}
