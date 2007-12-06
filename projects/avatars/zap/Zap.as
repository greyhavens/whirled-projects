package {

import flash.display.Graphics;
import flash.display.Sprite;
import flash.utils.ByteArray;
import flash.media.SoundMixer;
import flash.geom.Point;

import com.threerings.flash.FrameSprite;

import com.threerings.util.Log;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

[SWF(width="140", height="140")]
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
            // if we're moving do some semblence of rolling
            var orient :Number = _control.getOrientation();
            this.scaleX = Math.sqrt(Math.abs(Math.sin(Math.PI * orient / 180)));
            _canvas.rotation += (_control.getOrientation() < 180) ? 10 : -10;

        } else {
            // otherwise just idly turn
            _canvas.rotation += 1;
            this.scaleX = Math.sqrt(this.scaleX);
        }

        var from :Point = new Point(0, -30);
        var to :Point = new Point(0, 30);

        var bits :Array;
        var c1 :int, c2 :int, c3 :int;
        var w :Number;

        if (_speakFrames > 0) {
            _speakFrames -= 1;
            bits = [ 0xFFFFFF, 0xFFFFFF ];
            c1 = c2 = c3 = 0xFFFFFF;
            w = 3;

        } else {
            bits = summarizeSpectrum();

            c1 = 0xFFCC88;
            c2 = 0x88FFCC;
            c3 = 0xCC88FF;
            w = 1;
        }

        var g :Graphics = _canvas.graphics;
        g.clear();

        g.lineStyle(2, 0xDD9922);
        g.drawCircle(0, 0, 40);

        g.beginFill(bits[0]);
        g.drawCircle(0, -40, 9);
        g.endFill();

        g.beginFill(bits[1]);
        g.drawCircle(0, 40, 9);
        g.endFill();

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

    protected function summarizeSpectrum () :Array
    {
        var bytes :ByteArray = new ByteArray();
        SoundMixer.computeSpectrum(bytes, true);

        var leftLow :Number = 0, leftMid :Number = 0, leftHigh :Number = 0;
        var rightLow :Number = 0, rightMid :Number = 0, rightHigh :Number = 0;

        var ix :int;
        for (ix = 0; ix < IX_LOW; ix ++) {
            leftLow += bytes.readFloat() / IX_LOW;
        }
        for (ix = IX_LOW; ix < IX_MID; ix ++) {
            leftMid += bytes.readFloat() / (IX_MID - IX_LOW);
        }
        for (ix = IX_MID; ix < 256; ix ++) {
            leftHigh += bytes.readFloat() / (256-IX_MID);
        }
        for (ix = 0; ix < IX_LOW; ix ++) {
            rightLow += bytes.readFloat() / IX_LOW;
        }
        for (ix = IX_LOW; ix < IX_MID; ix ++) {
            rightMid += bytes.readFloat() / (IX_MID - IX_LOW);
        }
        for (ix = IX_MID; ix < 256; ix ++) {
            rightHigh += bytes.readFloat() / (256-IX_MID);
        }

        // convert the linear (0, 1) to logarithmic (decibel) scale
        leftLow = Math.LOG10E * Math.log(1 + 9 * leftLow);
        leftMid = Math.LOG10E * Math.log(1 + 9 * leftMid);
        leftHigh = Math.LOG10E * Math.log(1 + 9 * leftHigh);
        rightLow = Math.LOG10E * Math.log(1 + 9 * rightLow);
        rightMid = Math.LOG10E * Math.log(1 + 9 * rightMid);
        rightHigh = Math.LOG10E * Math.log(1 + 9 * rightHigh);

        var k :Number = 255;
        return [
            ((k * leftLow) << 16) + ((k * leftMid) << 8) + (k * leftHigh),
            ((k * rightLow) << 16) + ((k * rightMid) << 8) + (k * rightHigh)
        ];
    }

    protected static const IX_LOW :int = 4;
    protected static const IX_MID :int = 24;

    protected var _canvas :Sprite;
    protected var _control :AvatarControl;
    protected var _speakFrames :int;
}
}
