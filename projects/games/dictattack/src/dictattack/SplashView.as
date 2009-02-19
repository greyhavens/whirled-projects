//
// $Id$

package dictattack {

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.ByteArray;

import com.threerings.util.MultiLoader;

/**
 * Displays the splash screen.
 */
public class SplashView extends Sprite
{
    public function SplashView (ctx :Context, parent :DictionaryAttack)
    {
        _ctx = ctx;
        _parent = parent;
        MultiLoader.getContents(SPLASH, addSplash);

        addButton("Single Player", 130, function (event :MouseEvent) :void {
            parent.startGame();
        });
        addButton("Multiplayer", 280, function (event :MouseEvent) :void {
            parent.showLobby();
        });
        addButton("Trophies", 430, function (event :MouseEvent) :void {
            _ctx.control.local.showTrophies();
        });
        addButton("Help", 530, function (event :MouseEvent) :void {
            parent.showHelp();
        });
        addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
    }

    protected function addButton (label :String, xpos :int, onClick :Function) :void
    {
        var button :SimpleButton = _ctx.content.makeButton(label);
        button.addEventListener(MouseEvent.CLICK, onClick);
        button.x = xpos;
        button.y = 430;
        addChild(button);
    }

    protected function addSplash (splash :MovieClip) :void
    {
        _clip = splash;
        _clip.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        addChild(splash);
    }

    protected function onEnterFrame (event :Event) :void
    {
        if (_clip.currentFrame >= _clip.totalFrames) {
            _clip.gotoAndStop(35);
            _clip.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
    }

    protected function onRemoved (event :Event) :void
    {
        _clip.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    protected var _ctx :Context;
    protected var _clip :MovieClip;
    protected var _parent :DictionaryAttack;

    [Embed(source="../../rsrc/splash.swf", mimeType="application/octet-stream")]
    protected var SPLASH :Class;
}
}
