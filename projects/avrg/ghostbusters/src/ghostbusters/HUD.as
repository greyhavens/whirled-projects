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

    public function showArcs (show :Boolean) :void
    {
        if (_arcs == null) {
            return;
        }
        _arcs.graphics.clear();

        if (!show) {
            return;
        }

        _arcs.graphics.lineStyle(5, 0xFFFFFF);
	recursiveLightning(new Point(120, 40), new Point(120, 120), 50);
	recursiveLightning(new Point(150, 40), new Point(150, 120), 50);
	recursiveLightning(new Point(180, 40), new Point(180, 120), 50);
    }

    // this is a basic midpoint displacement algorithm, see e.g.
    // http://www.lotn.org/~calkinsc/graphics/mid.html
    protected function recursiveLightning (from :Point, to :Point, deviation :Number) :void
    {
        if (Point.distance(from, to) < 1) {
            _arcs.graphics.moveTo(from.x, from.y);
            _arcs.graphics.lineTo(to.x, to.y);
            return;
        }
        var midPoint :Point = new Point(
            (from.x + to.x)/2 + (Math.random() - 0.5) * deviation, (from.y + to.y)/2);
        recursiveLightning(from, midPoint, deviation/2);
        recursiveLightning(midPoint, to, deviation/2);
    }

    protected function handleHUDLoaded (evt :Event) :void
    {
        _hud = MovieClip(EmbeddedSwfLoader(evt.target).getContent());
        _hud.x = 20; // damn scrollbar
        _hud.y = 5;

        var button :DisplayObject;

        safelyAdd(LANTERN, lanternClick);
        safelyAdd(HELP, helpClick);
        safelyAdd(LOOT, lootClick);
        safelyAdd(CLOSE, closeClick);

        this.addChild(_hud);

        _arcs = new Sprite();
        this.addChild(_arcs);
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

    protected function lootClick (evt :Event) :void
    {
        CommandEvent.dispatch(this, GameController.TOGGLE_LOOT);
    }

    protected var _hud :MovieClip;
    protected var _arcs :Sprite;

    protected static const LANTERN :String = "button_lantern";
    protected static const HELP :String = "button_help";
    protected static const LOOT :String = "button_loot";
    protected static const CLOSE :String = "button_close";

    protected static const DEBUG :Boolean = false;
}
}
