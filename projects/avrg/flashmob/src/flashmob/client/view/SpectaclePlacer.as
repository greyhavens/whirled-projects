package flashmob.client.view {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

import flashmob.*;
import flashmob.client.*;
import flashmob.data.*;
import flashmob.util.SpriteUtil;

public class SpectaclePlacer extends DraggableObject
{
    public function SpectaclePlacer (spectacle :Spectacle, droppedCallback :Function = null)
    {
        super(null, droppedCallback);

        _spectacle = spectacle;
        // calculate the two-dimensional spectacle bounds
        var minX :Number = Number.POSITIVE_INFINITY;
        var maxX :Number = Number.NEGATIVE_INFINITY;
        var minY :Number = Number.POSITIVE_INFINITY;
        var maxY :Number = Number.NEGATIVE_INFINITY;
        for each (var pattern :Pattern in _spectacle.patterns) {
            for each (var loc :Vec3D in pattern.locs) {
                var p :Point = SpaceUtil.logicalToRoom(loc);
                minX = Math.min(minX, p.x);
                maxX = Math.max(maxX, p.x);
                minY = Math.min(minY, p.y);
                maxY = Math.max(maxY, p.y);
            }
        }
        _spectacleBounds2D = new Rectangle(0, 0, maxX - minX, maxY - minY);

        this.isDraggable = (droppedCallback != null);
        _sprite = SpriteUtil.createSprite(false, this.isDraggable);

        _frame = SwfResource.instantiateMovieClip(ClientCtx.rsrcs, "Spectacle_UI", "placer");
        _sprite.addChild(_frame);

        _tent = SwfResource.instantiateMovieClip(ClientCtx.rsrcs, "Spectacle_UI", "tent");
        _sprite.addChild(_tent);
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();

        // If we're not draggable, we don't want to intercept mouse clicks
        if (!this.isDraggable) {
            ClientCtx.hitTester.addExcludedObj(this.displayObject);
        }

        registerListener(ClientCtx.roomBoundsMonitor, GameEvent.ROOM_BOUNDS_CHANGED,
            updateBounds);
        updateBounds();
    }

    override protected function destroyed () :void
    {
        super.destroyed();

        if (!this.isDraggable) {
            ClientCtx.hitTester.removeExcludedObj(this.displayObject);
        }
    }

    protected function updateBounds (...ignored) :void
    {
        var bounds :Rectangle = SpaceUtil.roomToPaintableRect(_spectacleBounds2D);
        if (bounds.width < MIN_TENT_SIZE.x) {
            var dx :Number = MIN_TENT_SIZE.x - bounds.width;
            bounds.x -= dx / 2;
            bounds.width = MIN_TENT_SIZE.x;
        }

        if (bounds.height < MIN_TENT_SIZE.y) {
            var dy :Number = MIN_TENT_SIZE.y - bounds.height;
            bounds.y -= dy / 2;
            bounds.height = MIN_TENT_SIZE.y;
        }

        _frame.width = bounds.width + (BORDER_SIZE.x * 2);
        _frame.height = bounds.height + (BORDER_SIZE.y * 2);
        _frame.x = -_frame.width * 0.5;
        _frame.y = -_frame.height * 0.5;

        _tent.width = bounds.width;
        _tent.height = bounds.height;
        _tent.x = -_tent.width * 0.5;
        _tent.y = -_tent.height * 0.5;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _frame :MovieClip;
    protected var _tent :MovieClip;
    protected var _sprite :Sprite;
    protected var _spectacle :Spectacle;
    protected var _spectacleBounds2D :Rectangle;

    protected static var log :Log = Log.getLog(SpectaclePlacer);

    protected static const MIN_TENT_SIZE :Point = new Point(50, 50);
    protected static const BORDER_SIZE :Point = new Point(30, 30);
}

}
