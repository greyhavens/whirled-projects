package {

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;

[SWF(width="160", height="160")]
public class Zap extends Sprite
{
    public function Zap ()
    {
        this.addEventListener(Event.ADDED_TO_STAGE, start);
        this.addEventListener(Event.REMOVED_FROM_STAGE, stop);

        _canvas = new Sprite();
        this.addChild(_canvas);
        _canvas.x = 80;
        _canvas.y = 80;
        _canvas.scaleX = _canvas.scaleY = 1.6;
    }

    protected function start (ignored :*) :void
    {
        this.addEventListener(Event.ENTER_FRAME, frame);
    }

    protected function stop (ignored :*) :void
    {
        this.removeEventListener(Event.ENTER_FRAME, frame);
    }

    protected function frame (ignored :*) :void
    {
        _canvas.rotation += 1;

        with (_canvas.graphics) {
            clear();

            lineStyle(2, 0xFFAA44);
            drawCircle(0, 0, 40);

            drawCircle(0, -40, 9);
            drawCircle(0, 40, 9);
            endFill();
        }

        var from :Point = new Point(0, -30);
        var to :Point = new Point(0, 30);

        _canvas.graphics.lineStyle(1, 0xFFCC88);
	recursiveLightning(from, to, 50);

        _canvas.graphics.lineStyle(1, 0x88FFCC);
	recursiveLightning(from, to, 50);

        _canvas.graphics.lineStyle(1, 0xCC88FF);
	recursiveLightning(from, to, 50);
    }

    protected function recursiveLightning (from :Point, to :Point, deviation :Number) :void
    {
        if (Point.distance(from, to) < 1) {
            _canvas.graphics.moveTo(from.x, from.y);
            _canvas.graphics.lineTo(to.x, to.y);
            return;
        }
        var midPoint :Point = new Point(
            (from.x + to.x)/2 + (Math.random() - 0.5) * deviation, (from.y + to.y)/2);
        recursiveLightning(from, midPoint, deviation/2);
        recursiveLightning(midPoint, to, deviation/2);
    }

    protected var _canvas :Sprite;
}
}
