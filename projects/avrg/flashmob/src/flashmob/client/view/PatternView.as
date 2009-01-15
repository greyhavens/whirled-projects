package flashmob.client.view {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;

import flashmob.*;
import flashmob.client.*;
import flashmob.data.*;
import flashmob.util.SpriteUtil;

public class PatternView extends SceneObject
{
    public function PatternView (pattern :Pattern)
    {
        _pattern = pattern;
        _sprite = SpriteUtil.createSprite();
        for (var ii :int = 0; ii < _pattern.locs.length; ++ii) {
            var loc :PatternLoc = _pattern.locs[ii];
            var star :MovieClip = SwfResource.instantiateMovieClip("Spectacle_UI", "star", true,
                true);
            _sprite.addChild(star);
            _stars.push(star);
            _wasInPosition.push(false);
        }

        updateStarLocs();
        updateView();
    }

    override protected function addedToDB () :void
    {
        // Don't intercept mouse clicks
        ClientContext.hitTester.addExcludedObj(this.displayObject);

        registerListener(ClientContext.roomBoundsMonitor, GameEvent.ROOM_BOUNDS_CHANGED,
            updateStarLocs);
    }

    protected function updateStarLocs (...ignored) :void
    {
        for (var ii :int = 0; ii < _pattern.locs.length; ++ii) {
            var loc :PatternLoc = _pattern.locs[ii];
            var star :MovieClip = _stars[ii];

            var starLoc :Point =
                ClientContext.gameCtrl.local.roomToPaintable(new Point(loc.x, loc.y));
            star.x = starLoc.x;
            star.y = starLoc.y + Constants.ROOM_TO_PAINTABLE_Y_MAGIC;
        }
    }

    override protected function destroyed () :void
    {
        for each (var star :MovieClip in _stars) {
            SwfResource.releaseMovieClip(star);
        }

        ClientContext.hitTester.removeExcludedObj(this.displayObject);
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

    protected var _sprite :Sprite;
}

}
