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

        var bounds :Rectangle = _spectacle.getBounds();
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

        _movie = SwfResource.instantiateMovieClip("Spectacle_UI", "placer");
        _movie.width = bounds.width + (BORDER_SIZE.x * 2);
        _movie.height = bounds.height + (BORDER_SIZE.y * 2);
        _movie.x = bounds.left - BORDER_SIZE.x;
        _movie.y = bounds.top - BORDER_SIZE.y;
        _sprite.addChild(_movie);

        var tent :MovieClip = SwfResource.instantiateMovieClip("Spectacle_UI", "tent");
        tent.width = bounds.width;
        tent.height = bounds.height;
        tent.x = bounds.left;
        tent.y = bounds.top;
        _sprite.addChild(tent);
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
    }

    override protected function destroyed () :void
    {
        super.destroyed();

        if (!this.isDraggable) {
            ClientContext.hitTester.removeExcludedObj(this.displayObject);
        }
    }

    protected var _movie :MovieClip;
    protected var _sprite :Sprite;
    protected var _spectacle :Spectacle;

    protected static const MIN_TENT_SIZE :Point = new Point(100, 75);
    protected static const BORDER_SIZE :Point = new Point(30, 30);
}

}
