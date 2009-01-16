package flashmob.client.view {

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

        this.isDraggable = (droppedCallback != null);
        _sprite = SpriteUtil.createSprite(false, this.isDraggable);

        _frame = SwfResource.instantiateMovieClip("Spectacle_UI", "placer");
        _sprite.addChild(_frame);

        _tent = SwfResource.instantiateMovieClip("Spectacle_UI", "tent");
        _sprite.addChild(_tent);
    }

    protected function updateBounds (...ignored) :void
    {
        var bounds :Rectangle = SpaceUtil.logicalToPaintableRect(_spectacle.getBounds());
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
        _frame.x = bounds.left - BORDER_SIZE.x;
        _frame.y = bounds.top - BORDER_SIZE.y;

        _tent.width = bounds.width;
        _tent.height = bounds.height;
        _tent.x = bounds.left;
        _tent.y = bounds.top;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();

        // If we're not draggable, we don't want to intercept mouse clicks
        if (!this.isDraggable) {
            ClientContext.hitTester.addExcludedObj(this.displayObject);
        }

        registerListener(ClientContext.roomBoundsMonitor, GameEvent.ROOM_BOUNDS_CHANGED,
            updateBounds);
        updateBounds();
    }

    override protected function destroyed () :void
    {
        super.destroyed();

        if (!this.isDraggable) {
            ClientContext.hitTester.removeExcludedObj(this.displayObject);
        }
    }

    protected var _frame :MovieClip;
    protected var _tent :MovieClip;
    protected var _sprite :Sprite;
    protected var _spectacle :Spectacle;

    protected static const MIN_TENT_SIZE :Point = new Point(100, 75);
    protected static const BORDER_SIZE :Point = new Point(30, 30);
}

}
