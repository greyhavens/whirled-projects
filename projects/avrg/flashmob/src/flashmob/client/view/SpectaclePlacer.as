package flashmob.client.view {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
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

        // Create the view
        var shape :Shape = new Shape();
        _sprite.addChild(shape);
        var g :Graphics = shape.graphics;

        var bounds :Rectangle = _spectacle.getBounds();
        var borderSize :Number = Constants.PATTERN_DOT_SIZE + 3;
        g.lineStyle(2, 0);
        g.beginFill(0x0000FF, 0.4);
        g.drawRoundRect(
            bounds.left - borderSize,
            bounds.top - borderSize,
            bounds.width + (borderSize * 2),
            bounds.height + (borderSize * 2),
            Constants.PATTERN_DOT_SIZE + 3,
            Constants.PATTERN_DOT_SIZE + 3);
        g.endFill();

        /*for (var ii :int = _spectacle.patterns.length - 1; ii >=0; --ii) {
            var pattern :Pattern = _spectacle.patterns[ii];
            var isFirstPattern :Boolean = (ii == 0);
            for each (var loc :PatternLoc in pattern.locs) {
                g.beginFill(0xFFFFFF, (isFirstPattern ? 1 : 0.3));
                g.drawCircle(loc.x, loc.y, Constants.PATTERN_DOT_SIZE);
                g.endFill();

                if (isFirstPattern) {
                    g.beginFill(0xFF0000);
                    g.drawCircle(loc.x, loc.y, Constants.PATTERN_DOT_SIZE / 4);
                    g.endFill();
                }
            }
        }*/
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

    protected var _sprite :Sprite;
    protected var _spectacle :Spectacle;
}

}
