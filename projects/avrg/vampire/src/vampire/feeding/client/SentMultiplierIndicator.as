package vampire.feeding.client {

import com.threerings.display.DisplayUtil;
import com.threerings.geom.Vector2;
import com.threerings.flashbang.objects.SceneObject;
import com.threerings.flashbang.resource.SwfResource;
import com.threerings.flashbang.tasks.*;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.geom.Point;

import vampire.feeding.*;

public class SentMultiplierIndicator extends SceneObject
{
    public function SentMultiplierIndicator (loc :Vector2)
    {
        _movie = ClientCtx.instantiateMovieClip("blood", "sent_panel", true, true);

        var flyToMovie :MovieClip = _movie["placeholder"];
        _flyToLoc.x = flyToMovie.x + SHOW_OFFSET.x;
        _flyToLoc.y = flyToMovie.y + SHOW_OFFSET.y;

        _loc = loc;
        this.x = _loc.x;
        this.y = _loc.y;
    }

    public function showAnim (multiplier :int, x :int, y :int) :void
    {
        var anim :SentMultiplierAnim = new SentMultiplierAnim(
            multiplier,
            new Point(x, y),
            DisplayUtil.transformPoint(_flyToLoc, this.displayObject, GameCtx.effectLayer),
            slideUp,
            function () :void {
                attachBonusAnim(anim);
            });

        GameCtx.gameMode.addSceneObject(anim, GameCtx.effectLayer);
    }

    protected function slideUp () :void
    {
        if (!_showing) {
            _showing = true;
            addTask(LocationTask.CreateSmooth(_loc.x + SHOW_OFFSET.x, _loc.y + SHOW_OFFSET.y, 0.5));
        }

        // If the indicator is already showing, don't reshow it - just extend the amount of
        // time it remains on the screen
        addNamedTask("Hide",
            new SerialTask(
                new TimedTask(1.5),
                LocationTask.CreateSmooth(_loc.x, _loc.y, 0.5),
                new FunctionTask(function () :void {
                    _showing = false;
                    for each (var anim :SentMultiplierAnim in _attachedAnims) {
                        anim.destroySelf();
                    }
                    _attachedAnims = [];
                })),
            true);
    }

    protected function attachBonusAnim (anim :SentMultiplierAnim) :void
    {
        anim.x = _flyToLoc.x - SHOW_OFFSET.x;
        anim.y = _flyToLoc.y - SHOW_OFFSET.y;
        (this.displayObject as DisplayObjectContainer).addChild(anim.displayObject);
        _attachedAnims.push(anim);
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
        super.destroyed();
    }

    protected var _movie :MovieClip;
    protected var _showing :Boolean;
    protected var _flyToLoc :Point = new Point();
    protected var _attachedAnims :Array = [];

    protected var _loc :Vector2;

    protected static const SHOW_OFFSET :Vector2 = new Vector2(0, -30);
}

}

import com.threerings.geom.Vector2;
import com.threerings.flashbang.objects.SceneObject;
import com.threerings.flashbang.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;

import mx.effects.easing.Cubic;
import mx.effects.easing.Linear;

import vampire.feeding.*;
import vampire.feeding.client.*;

class SentMultiplierAnim extends SceneObject
{
    public function SentMultiplierAnim (multiplier :int, start :Point, end :Point,
                                        startFlyingCallback :Function,
                                        stopFlyingCallback :Function)
    {
        _movie = ClientCtx.instantiateMovieClip("blood", "cell_coop_create");

        this.x = start.x;
        this.y = start.y;
        this.scaleX = this.scaleY = SCALE_UP;

        // Fly to the SentMultiplierIndicator, and hand off to it
        var thisAnim :SentMultiplierAnim = this;
        addTask(new SerialTask(
            new WaitForFrameTask(54),
            new FunctionTask(function () :void {
                _movie.addChild(Cell.createMultiplierText(multiplier, 15, 15));
            }),
            new TimedTask(0.5),
            new FunctionTask(startFlyingCallback),
            new ParallelTask(
                new AdvancedLocationTask(
                    end.x,
                    end.y,
                    0.75,
                    mx.effects.easing.Linear.easeNone,
                    mx.effects.easing.Cubic.easeIn),
                new SerialTask(
                    new TimedTask(0.5),
                    new ScaleTask(SCALE_DOWN, SCALE_DOWN, 0.25))),
            new FunctionTask(stopFlyingCallback)));
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _movie :MovieClip;

    protected static const SEND_LOC :Vector2 = new Vector2(506, 69);

    protected static const SCALE_UP :Number = 2;
    protected static const SCALE_DOWN :Number = 1;
}
