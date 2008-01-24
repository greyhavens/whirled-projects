//
// $Id$

package ghostbusters {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.ByteArray;
import flash.utils.setTimeout;

import com.threerings.flash.DisplayUtil;
import com.threerings.util.CommandEvent;

import ghostbusters.GameController;

import com.threerings.util.EmbeddedSwfLoader;

public class HUD extends Sprite
{
    public function HUD ()
    {
        var loader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
        loader.addEventListener(Event.COMPLETE, handleHUDLoaded);
        loader.load(ByteArray(new Content.HUD_VISUAL()));
    }

    public function shutdown () :void
    {
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return _hud != null && _hud.hitTestPoint(x, y, shapeFlag);
    }

    public function resized () :void
    {
        if (_hud != null) {
            placeHud();
        }
    }

    protected function handleHUDLoaded (evt :Event) :void
    {
        _hud = MovieClip(EmbeddedSwfLoader(evt.target).getContent());

        safelyAdd(LANTERN, lanternClick);
        safelyAdd(HELP, helpClick);
        safelyAdd(CLOSE, closeClick);

        this.addChild(_hud);

        if (Game.scrollSize != null && Game.stageSize != null) {
            placeHud();
        }
    }

    protected function placeHud () :void
    {
        // put the HUD to the right of the visible screen, or flush with the stage edge
        _hud.x = Math.min(Game.scrollSize.right - MARGIN_LEFT,
                          Game.stageSize.right - _hud.width);
        _hud.y = 0;

        var width :int = Game.stageSize.right - Game.scrollSize.right;
        if (width > 0) {
            this.graphics.beginFill(0);
            this.graphics.drawRect(Game.scrollSize.right + 1, 1,
                                   width, Game.scrollSize.height);
            this.graphics.endFill();
        }
    }

    protected function safelyAdd (name :String, callback :Function) :void
    {
        var button :DisplayObject = DisplayUtil.findInHierarchy(_hud, name);
        if (button == null) {
            Game.log.warning("Could not find button: " + name);
            return;
        }
        button.addEventListener(MouseEvent.CLICK, callback);
    }

    protected function lanternClick (evt :Event) :void
    {
        CommandEvent.dispatch(this, GameController.TOGGLE_LANTERN);
    }

    protected function closeClick (evt :Event) :void
    {
        CommandEvent.dispatch(this, GameController.END_GAME);
    }

    protected function helpClick (evt :Event) :void
    {
        CommandEvent.dispatch(this, GameController.HELP);
    }

//    protected function lootClick (evt :Event) :void
//    {
//        CommandEvent.dispatch(this, GameController.TOGGLE_LOOT);
//    }

    protected var _hud :MovieClip;

    protected static const LANTERN :String = "weaponbutton";
    protected static const HELP :String = "helpbutton";
    protected static const CLOSE :String = "closeButton";

    protected static const DEBUG :Boolean = false;

    protected static const MARGIN_LEFT :int = 47;
}
}
