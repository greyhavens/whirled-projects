//
// $Id$

package ghostbusters {

import flash.display.MovieClip;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.ByteArray;

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

    protected function handleHUDLoaded (evt :Event) :void
    {
        _hud = MovieClip(EmbeddedSwfLoader(evt.target).getContent());
        _hud.x = 20; // damn scrollbar
        _hud.y = 5;

        DisplayUtil.findInHierarchy(_hud, LANTERN).addEventListener(MouseEvent.CLICK, lanternClick);
        DisplayUtil.findInHierarchy(_hud, HELP).addEventListener(MouseEvent.CLICK, helpClick);
        DisplayUtil.findInHierarchy(_hud, LOOT).addEventListener(MouseEvent.CLICK, lootClick);

        this.addChild(_hud);
    }

    protected function lanternClick (evt :Event) :void
    {
        CommandEvent.dispatch(this, GameController.TOGGLE_LANTERN);
    }

    protected function helpClick (evt :Event) :void
    {
        CommandEvent.dispatch(this, GameController.HELP);
    }

    protected function lootClick (evt :Event) :void
    {
        CommandEvent.dispatch(this, GameController.TOGGLE_LOOT);
    }

    protected var _hud :MovieClip;

    protected static const LANTERN :String = "lanternbutton";
    protected static const HELP :String = "helpbutton";
    protected static const LOOT :String = "lootbutton";

    protected static const DEBUG :Boolean = false;
}
}
