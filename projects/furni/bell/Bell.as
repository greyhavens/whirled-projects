package {

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.geom.Point;

import flash.media.Sound;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

/**
 * <code>Bell</code> is a simple ringable bell.
 */
[SWF(width="100", height="100")]
public class Bell extends Sprite
{
    public function Bell ()
    {
        // Create a sprite to hold the bell and listen for the click event.
        var furni :Sprite = new Sprite();
        furni.addEventListener(MouseEvent.CLICK, clickHandler);
        addChild(furni);

        // Scale the bell so it fits inside our SWF.
        var scale :Number = Math.min(100/_bellImg.width, 100/_bellImg.height);
        _bellImg.scaleX = _bellImg.scaleY = scale;
        furni.addChild(_bellImg);

        _control = new FurniControl(this);
        _control.addEventListener(ControlEvent.MESSAGE_RECEIVED, function (... ignored) :void {
            ding();
        });
    }

    public function clickHandler (event :MouseEvent) :void
    {
        // Mouse events trigger even on transparent pixels, so we have to test the bitmap data.
        var p :Point = _bellImg.globalToLocal(new Point(event.stageX, event.stageY));
        if (_bellImg.bitmapData.hitTest(new Point(0, 0), 0, p)) {
            if (_control.isConnected()) {
                _control.sendMessage("ding");
            }
            ding();
        }
    }

    protected function ding () :void
    {
        _bellSnd.play();
    }

    protected var _control :FurniControl;

    // An instance of the bell image to use
    protected var _bellImg :Bitmap = new _bellImgClass();

    // An instance of the bell chime to use
    protected var _bellSnd :Sound = new _bellSndClass();

    // A (remixable) bell image asset
    [Embed(source="Bell.png")]
    protected static const _bellImgClass :Class;

    // A (remixable) bell sound asset
    [Embed(source="Bell.mp3")]
    protected static const _bellSndClass :Class;
}
}
