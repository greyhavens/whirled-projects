//
// $Id$

package ghostbusters {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.geom.Point;

import com.threerings.flash.AlphaFade;

import com.threerings.util.Log;

public class Box extends Sprite
{
    public function Box (innards :DisplayObject)
    {
        _clipHolder = new Sprite();
        _clipHolder.addChild(_boxAppearClip);
        _clipHolder.addChild(_boxClip);
        _clipHolder.addChild(_boxDisappearClip);

        _boxAppearHandler = new ClipHandler(_boxAppearClip);
        _boxDisappearHandler = new ClipHandler(_boxDisappearClip);
        setVisibleClip(null);

        _clipHolder.x = _boxClip.width / 2;
        _clipHolder.y = _boxClip.height / 2;

        _backdrop = new Sprite();
        _backdrop.addChild(_clipHolder);
        this.addChild(_backdrop);

        _foreground = new Sprite();
        _foreground.addChild(innards);
        this.addChild(_foreground);

        innards.y = BOX_PADDING;
        innards.x = BOX_PADDING;

        _backdrop.scaleX = innards.width / _boxClip.width;
        _backdrop.scaleY = innards.height / _boxClip.height;

        log.debug("Scaled to: (" + _backdrop.scaleX + ", " + _backdrop.scaleY + ")");

        _fadeIn = new AlphaFade(_foreground, 0, 1, 300);
        _fadeOut = new AlphaFade(_foreground, 1, 0, 300, function () :void {
            _foreground.visible = false;
            setVisibleClip(_boxDisappearClip);
            _boxDisappearHandler.gotoSceneNumber(0, function() :void {
                setVisibleClip(null);
            });
        });
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

        if (_fadeOut.isPlaying()) {
            _fadeOut.stopAnimation();
        }

        setVisibleClip(_boxAppearClip);
        _boxAppearHandler.gotoSceneNumber(0, function () :void {
            _fadeIn.startAnimation();
            setVisibleClip(_boxClip);
            _foreground.visible = true;
        });

        _backdrop.visible = this.visible = true;
    }

    protected function setVisibleClip (box :MovieClip) :void
    {
        _boxAppearClip.visible = (box == _boxAppearClip);
        _boxClip.visible = (box == _boxClip);
        _boxDisappearClip.visible = (box == _boxDisappearClip);
    }

    protected var _clipHolder :Sprite;
    protected var _backdrop :Sprite;
    protected var _foreground :Sprite;

    protected var _fadeOut :AlphaFade;
    protected var _fadeIn :AlphaFade;

    protected var _boxClip :MovieClip = MovieClip(new TEXT_BOX());
    protected var _boxAppearClip :MovieClip = MovieClip(new TEXT_BOX_APPEAR());
    protected var _boxAppearHandler :ClipHandler;
    protected var _boxDisappearClip :MovieClip = MovieClip(new TEXT_BOX_DISAPPEAR());
    protected var _boxDisappearHandler :ClipHandler;

    protected static const log :Log = Log.getLog(TextBox);

    protected static const BOX_PADDING :int = 10;

    [Embed(source="../../rsrc/text_box.swf#textbox_appear")]
    protected static const TEXT_BOX_APPEAR :Class;

    [Embed(source="../../rsrc/text_box.swf#textbox")]
    protected static const TEXT_BOX :Class;

    [Embed(source="../../rsrc/text_box.swf#textbox_disappear")]
    protected static const TEXT_BOX_DISAPPEAR :Class;
}
}
