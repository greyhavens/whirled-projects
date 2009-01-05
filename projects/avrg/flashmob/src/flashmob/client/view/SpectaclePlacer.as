package flashmob.client.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

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

public class SpectaclePlacer extends SceneObject
{
    public function SpectaclePlacer (spectacle :Spectacle, draggedCallback :Function = null)
    {
        _spectacle = spectacle;
        _draggedCallback = draggedCallback;

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

        for (var ii :int = _spectacle.patterns.length - 1; ii >=0; --ii) {
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
        }

        if (this.isDraggable) {
            registerListener(_sprite, MouseEvent.MOUSE_DOWN, startDrag);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function addedToDB () :void
    {
        // If we're not draggable, we don't want to intercept mouse clicks
        if (!this.isDraggable) {
            ClientContext.hitTester.addExcludedObj(this.displayObject);
        }
    }

    override protected function destroyed () :void
    {
        if (!this.isDraggable) {
            ClientContext.hitTester.removeExcludedObj(this.displayObject);
        }
    }

    protected function startDrag (...ignored) :void
    {
        if (!_dragging) {
            _dragOffsetX = -_sprite.mouseX;
            _dragOffsetY = -_sprite.mouseY;
            _dragging = true;

            registerListener(_sprite, MouseEvent.MOUSE_UP, endDrag);
        }
    }

    protected function endDrag (...ignored) :void
    {
        unregisterListener(_sprite, MouseEvent.MOUSE_UP, endDrag);
        updateDraggedLocation();

        _dragging = false;
    }

    protected function updateDraggedLocation () :void
    {
        if (_sprite.parent != null) {
            var newX :Number = _sprite.parent.mouseX + _dragOffsetX;
            var newY :Number = _sprite.parent.mouseY + _dragOffsetY;
            if (newX != this.x || newY != this.y) {
                this.x = newX;
                this.y = newY;
                _draggedCallback(newX, newY);
            }
        }
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (_dragging) {
            updateDraggedLocation();
        }
    }

    protected function get isDraggable () :Boolean
    {
        return (_draggedCallback != null);
    }

    protected var _sprite :Sprite;
    protected var _spectacle :Spectacle;
    protected var _draggedCallback :Function;

    protected var _dragOffsetX :Number;
    protected var _dragOffsetY :Number;
    protected var _dragging :Boolean;
}

}
