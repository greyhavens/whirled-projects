//
// $Id$

package ghostbusters {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;

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

        _arcs = new Sprite();
        this.addChild(_arcs);
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
        _arcs.graphics.clear();

        if (!show) {
            return;
        }

        var from :Point = new Point(30, 50);
        var to :Point = new Point(130, 30);

        _arcs.graphics.lineStyle(5, 0xFFFFFF);

	recursiveLightning(from, to, 50);
        from.y += 20;
        to.y += 20;

	recursiveLightning(from, to, 50);
        from.y += 20;
        to.y += 20;

	recursiveLightning(from, to, 50);
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
    protected var _arcs :Sprite;

    protected static const LANTERN :String = "lanternbutton";
    protected static const HELP :String = "helpbutton";
    protected static const LOOT :String = "lootbutton";

    protected static const DEBUG :Boolean = false;
}
}
