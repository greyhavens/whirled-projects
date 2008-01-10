//
// $Id$

package ghostbusters {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.geom.Point;
import flash.geom.Rectangle;

import com.threerings.flash.AlphaFade;

public class Box extends Sprite
{
    public function Box (innards :DisplayObject)
    {
        _innards = innards;
        _boxHandler = new ClipHandler(new Content.TEXT_BOX(), initUI);
    }

    protected function initUI (clip :MovieClip) :void
    {
        _boxClip = clip;
        Game.log.debug("Box clip dimensions: " + _boxClip.getBounds(_boxClip));

        _boxHandler.gotoScene(SCN_BOX);
        Game.log.debug("Box clip dimensions: " + _boxClip.getBounds(_boxClip));

        _backdrop = new Sprite();
        _backdrop.addChild(_boxClip);

        var bounds :Rectangle = _boxClip.getBounds(_backdrop);

//        _boxClip.x = -_boxClip.width / 2;
//        _boxClip.y = -_boxClip.height / 2;
        Game.log.debug("Backdrop dimensions: " + _backdrop.getBounds(_backdrop));

        this.addChild(_backdrop);

        _foreground = new Sprite();
        _foreground.addChild(_innards);
        this.addChild(_foreground);

        Game.log.debug("Innards dimensions: " + _foreground.getBounds(this));

        _innards.y = 50;
        _innards.x = 50;

        _backdrop.scaleX = _foreground.width / (_boxClip.width - 100);
        _backdrop.scaleY = _foreground.height / (_boxClip.height - 100);

        Game.log.debug("Scaled to: (" + _backdrop.scaleX + ", " + _backdrop.scaleY + ")");
        Game.log.debug("New backdrop dimensions: " + _backdrop.getBounds(this));

        _fadeIn = new AlphaFade(_foreground, 0, 1, 300);
        _fadeOut = new AlphaFade(_foreground, 1, 0, 300, function () :void {
            _foreground.visible = false;
            _boxHandler.gotoScene(SCN_BOX_DISAPPEAR, function() :void {
                _boxHandler.stop();
                _backdrop.visible = false;
            });
        });

        show();
    }

    public function hide () :void
    {
        if (_fadeIn.isPlaying()) {
            _fadeIn.stopAnimation();
        }
        _fadeOut.startAnimation();
    }

    public function show () :void
    {
        _foreground.visible = false;

        Game.log.debug("WHAT THE FUCK");

        if (_fadeOut.isPlaying()) {
            _fadeOut.stopAnimation();
        }

        _boxHandler.gotoScene(SCN_BOX_APPEAR, function () :void {
                Game.log.debug("DONEEEE");
            _fadeIn.startAnimation();
            _boxHandler.gotoScene(SCN_BOX);
            _foreground.visible = true;
        });

        _backdrop.visible = this.visible = true;
    }

    protected var _innards :DisplayObject;
    protected var _boxClip :Sprite;
    protected var _backdrop :Sprite;
    protected var _foreground :Sprite;

    protected var _fadeOut :AlphaFade;
    protected var _fadeIn :AlphaFade;

    protected var _boxHandler :ClipHandler;

    protected static const PADDING_LEFT :int = 100;
    protected static const PADDING_RIGHT :int = 50;
    protected static const PADDING_TOP :int = 40;
    protected static const PADDING_BOTTOM :int = 70;



    protected static const SCN_BOX :String = "textbox";
    protected static const SCN_BOX_APPEAR :String = "textbox_appear";
    protected static const SCN_BOX_DISAPPEAR :String = "textbox_disappear";
}
}
