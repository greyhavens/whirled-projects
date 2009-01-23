package flashmob.client.view {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import flashmob.*;
import flashmob.client.*;
import flashmob.data.*;
import flashmob.util.SpriteUtil;

public class PatternView extends SceneObject
{
    public function PatternView (pattern :Pattern, locClickedCallback :Function = null)
    {
        _pattern = pattern;
        _onLocClicked = locClickedCallback;

        _sprite = SpriteUtil.createSprite(_onLocClicked != null, false);

        var localPlayerIndex :int = ClientCtx.localPlayerIndex;
        for (var ii :int = 0; ii < _pattern.locs.length; ++ii) {
            var loc :Vec3D = _pattern.locs[ii];
            var star :MovieClip = SwfResource.instantiateMovieClip(ClientCtx.rsrcs, "Spectacle_UI", "star", false,
                true);

            _sprite.addChild(star);
            _stars.push(star);
            _wasInPosition.push(false);
            star.scaleX = star.scaleY = (ii == localPlayerIndex ? 1.5 : 0.8);

            if (_onLocClicked != null) {
                registerListener(star, MouseEvent.CLICK, createStarClickListener(loc));
            }
        }

        updateStarLocs();
        updateView();
    }

    protected function createStarClickListener (loc :Vec3D) :Function
    {
        return function (...ignored) :void {
            _onLocClicked(loc);
        }
    }

    override protected function addedToDB () :void
    {
        // Don't intercept mouse clicks
        //ClientContext.hitTester.addExcludedObj(this.displayObject);

        registerListener(ClientCtx.roomBoundsMonitor, GameEvent.ROOM_BOUNDS_CHANGED,
            updateStarLocs);
    }

    override protected function destroyed () :void
    {
        for each (var star :MovieClip in _stars) {
            SwfResource.releaseMovieClip(star);
        }

        //ClientContext.hitTester.removeExcludedObj(this.displayObject);
    }

    protected function updateStarLocs (...ignored) :void
    {
        for (var ii :int = 0; ii < _pattern.locs.length; ++ii) {
            var loc :Vec3D = _pattern.locs[ii];
            var star :MovieClip = _stars[ii];

            var starLoc :Point = SpaceUtil.logicalToPaintable(loc);
            star.x = starLoc.x;
            star.y = starLoc.y;
            //log.info("Star " + ii, "logical", loc, "paintable", starLoc);
        }
    }

    public function showInPositionIndicators (inPositionFlags :Array) :void
    {
        updateView(inPositionFlags);
    }

    protected function updateView (inPositionFlags :Array = null) :void
    {
        for (var ii :int = 0; ii < _stars.length; ++ii) {
            var star :MovieClip = _stars[ii];
            var inPosition :Boolean = (inPositionFlags != null ? inPositionFlags[ii] : false);
            if (inPosition != _wasInPosition[ii]) {
                star.gotoAndPlay(inPosition ? "gotstar" : "seekstar");
                _wasInPosition[ii] = inPosition;
            }
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _pattern :Pattern;
    protected var _stars :Array = [];
    protected var _wasInPosition :Array = [];
    protected var _onLocClicked :Function;

    protected var _sprite :Sprite;

    protected static var log :Log = Log.getLog(PatternView);
}

}
