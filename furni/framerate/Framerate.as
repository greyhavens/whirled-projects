package {

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.TimeBuffer;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.getTimer;

[SWF(width="400", height="100", framerate="30")]
public class Framerate extends Sprite
{
    public function Framerate ()
    {
        _events.registerListener(this, Event.ADDED_TO_STAGE, onAdded);
        _events.registerListener(this, Event.REMOVED_FROM_STAGE, onRemoved);

        var g :Graphics = this.graphics;
        g.lineStyle(4, 0);
        g.beginFill(0xffffff);
        g.drawRect(0, 0, 400, 100);
        g.endFill();

        _tf = new TextField();
        addChild(_tf);
    }

    protected function onEnterFrame (... ignored) :void
    {
        if (_lastTime < 0) {
            _lastTime = flash.utils.getTimer();
            return;
        }

        var time :int = flash.utils.getTimer();
        var dt :int = time - _lastTime;
        var fps :Number = 1000 / dt;

        // calculate fps average
        _fpsBuffer.push(fps);
        var sumFps :Number = 0;
        var minFps :Number = Number.MAX_VALUE;
        var maxFps :Number = Number.MIN_VALUE;
        _fpsBuffer.forEach(function (num :Number, timestamp :int) :void {
            sumFps += num;
            minFps = Math.min(minFps, num);
            maxFps = Math.max(maxFps, num);
        });
        var avgFps :Number = sumFps / _fpsBuffer.length;

        var text :String = "Cur=" + Math.round(fps) +
                           "\nAvg=" + Math.round(avgFps) +
                           " Min=" + Math.round(minFps) +
                           " Max=" + Math.round(maxFps) +
                           " (last " + TIME_WINDOW + "s)";

        initTextField(_tf, text, 2, 0, (avgFps <= SLOW_FPS ? 0xff0000 : 0x0000ff));
        _tf.x = (this.width - _tf.width) * 0.5;
        _tf.y = (this.height - _tf.height) * 0.5;

        _lastTime = time;
    }

    protected function onAdded (... ignored) :void
    {
        _events.registerListener(this, Event.ENTER_FRAME, onEnterFrame);
    }

    protected function onRemoved (... ignored) :void
    {
        _events.freeAllHandlers();
    }

    protected static function initTextField (tf :TextField, text :String, textScale :Number,
        maxWidth :int, textColor :Number, align :String = "center") :void
    {
        var wordWrap :Boolean = (maxWidth > 0);

        tf.mouseEnabled = false;
        tf.selectable = false;
        tf.multiline = true;
        tf.wordWrap = wordWrap;
        tf.scaleX = textScale;
        tf.scaleY = textScale;

        if (wordWrap) {
            tf.width = maxWidth / textScale;
        } else {
            tf.autoSize = TextFieldAutoSize.LEFT;
        }

        tf.text = text;

        if (wordWrap) {
            // if the text isn't as wide as maxWidth, shrink the TextField
            tf.width = tf.textWidth + TEXT_WIDTH_PAD;
            tf.height = tf.textHeight + TEXT_HEIGHT_PAD;
        }

        var format :TextFormat = tf.defaultTextFormat;
        format.align = align;

        if (textColor > 0) {
            format.color = textColor;
        }

        tf.setTextFormat(format);
    }

    protected var _lastTime :int = -1;

    protected var _tf :TextField;
    protected var _fpsBuffer :TimeBuffer = new TimeBuffer(TIME_WINDOW * 1000, 128);
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static const SLOW_FPS :Number = 15;
    protected static const TIME_WINDOW :int = 5; // in seconds

    protected static const TEXT_WIDTH_PAD :int = 5;
    protected static const TEXT_HEIGHT_PAD :int = 4;
}

}
