package {

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;

public class TowerSprite extends Sprite
{
    public var display :Display;
    
    public function TowerSprite (type :int, display :Display)
    {
        this.display = display;

        _bitmap = AssetFactory.makeTower(type);
        addChild(_bitmap);

        this.scaleX = display.def.squareWidth / _bitmap.width;
        this.scaleY = display.def.squareHeight / _bitmap.height;
        _hotspot = new Point(_bitmap.width / 2, _bitmap.height / 2);
    }

    /**
     * Given logical board coordinates, find the appropriate screen position,
     * and moves the sprite there.
     */
    public function move (x :int, y :int) :void
    {
        var p :Point = display.def.logicalToScreen(x, y);
        this.x = p.x - _hotspot.x * scaleX;
        this.y = p.y - _hotspot.y * scaleY;
    }

    /**
     * Sets cursor as enabled or disabled.
     */
    public function set enabled (value :Boolean) :void
    {
        _bitmap.alpha = value ? 1.0 : 0.3;
    }

    protected var _bitmap :DisplayObject;
    protected var _hotspot :Point = new Point(0, 0);
}
}
