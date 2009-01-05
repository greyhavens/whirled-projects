package flashmob.client.view {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;

import flashmob.client.*;
import flashmob.data.*;
import flashmob.util.SpriteUtil;

public class PatternView extends SceneObject
{
    public function PatternView (pattern :Pattern, draggedCallback :Function = null)
    {
        _pattern = pattern;
        _draggedCallback = draggedCallback;

        _sprite = SpriteUtil.createSprite(false, this.isDraggable);
        _shape = new Shape();
        _sprite.addChild(_shape);

        updateView();

        if (this.isDraggable) {
            registerListener(_sprite, MouseEvent.MOUSE_DOWN, startDrag);
        }
    }

    public function showInPositionIndicators (inPositionFlags :Array) :void
    {
        updateView(inPositionFlags);
    }

    protected function updateView (inPositionFlags :Array = null) :void
    {
        var g :Graphics = _shape.graphics;
        g.clear();
        g.lineStyle(2, 0);

        for (var ii :int = 0; ii < _pattern.locs.length; ++ii) {
            var loc :PatternLoc = _pattern.locs[ii];
            var inPosition :Boolean = (inPositionFlags != null ? inPositionFlags[ii] : false);
            g.beginFill(inPosition ? 0x00FF00 : 0xFFFFFF);
            g.drawCircle(loc.x, loc.y, 12);
            g.endFill();
        }
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

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function get isDraggable () :Boolean
    {
        return (_draggedCallback != null);
    }

    protected static function get log () :Log
    {
        return FlashMobClient.log;
    }

    protected var _pattern :Pattern;
    protected var _draggedCallback :Function;

    protected var _sprite :Sprite;
    protected var _shape :Shape;

    protected var _dragOffsetX :Number;
    protected var _dragOffsetY :Number;
    protected var _dragging :Boolean;
}

}
