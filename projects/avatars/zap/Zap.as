package {

import flash.display.Sprite;
import flash.geom.Point;

import com.threerings.flash.FrameSprite;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

[SWF(width="160", height="160")]
public class Zap extends FrameSprite
{
    public function Zap ()
    {
        super(true);

        _canvas = new Sprite();
        _canvas.x = 70;
        _canvas.y = 70;
        _canvas.scaleX = _canvas.scaleY = 1.4;
        this.addChild(_canvas);

        _control = new AvatarControl(this);

        _control.addEventListener(ControlEvent.AVATAR_SPOKE, avatarSpoke);

//        _control.addEventListener(ControlEvent.ACTION_TRIGGERED, handleAction);
//        _control.registerActions("");

//        _control.addEventListener(ControlEvent.STATE_CHANGED, handleAction);
//        _control.registerStates("");
    }

    protected function avatarSpoke (... ignored) :void
    {
        _speakFrames = 20;
    }

    protected override function handleFrame (... ignored) :void
    {
        if (_control.isMoving()) {
            var orient :Number = _control.getOrientation();
            this.scaleX = Math.abs(Math.sin(Math.PI * orient / 180));
            _canvas.rotation += (_control.getOrientation() < 180) ? 10 : -10;
        } else {
            this.scaleX = Math.sqrt(this.scaleX);
        }

        with (_canvas.graphics) {
            clear();

            lineStyle(2, 0xFFAA44);
            drawCircle(0, 0, 40);

            beginFill(0x000000);
            drawCircle(0, -40, 9);
            drawCircle(0, 40, 9);
            endFill();
        }

        var from :Point = new Point(0, -30);
        var to :Point = new Point(0, 30);

        var c1 :Number, c2 :Number, c3 :Number, w :Number;
        if (_speakFrames > 0) {
            _speakFrames -= 1;
            c1 = c2 = c3 = 0xFFFFFF;
            w = 3;

        } else {
            c1 = 0xFFCC88;
            c2 = 0x88FFCC;
            c3 = 0xCC88FF;
            w = 1;
        }

        _canvas.graphics.lineStyle(w, c1);
	recursiveLightning(from, to, 50);

        _canvas.graphics.lineStyle(w, c2);
	recursiveLightning(from, to, 50);

        _canvas.graphics.lineStyle(w, c3);
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
    protected var _control :AvatarControl;
    protected var _speakFrames :int;
}
}
