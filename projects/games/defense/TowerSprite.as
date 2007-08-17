package {

import flash.geom.Point;
import mx.controls.Image;

public class TowerSprite extends Image
{
    public var display :Display;
    public var type :int;
    
    public function TowerSprite (type :int, display :Display)
    {
        this.display = display;
        this.type = type;
    }

    /**
     * Given logical board coordinates, find the appropriate screen position,
     * and moves the sprite there.
     */
    public function setBoardPosition (x :int, y :int) :void
    {
        var p :Point = display.def.logicalToScreen(x, y);
        this.x = p.x - _hotspot.x * scaleX;
        this.y = p.y - _hotspot.y * scaleY;
    }

    /**
     * Sets cursor as enabled or disabled.
     */
    public function setState (value :Boolean) :void
    {
        this.alpha = value ? 1.0 : 0.3;
    }

    override protected function createChildren () :void
    {
        super.createChildren();
        
        this.source = AssetFactory.makeTower(type);

        this.scaleX = display.def.squareWidth / source.width;
        this.scaleY = display.def.squareHeight / source.height;
        _hotspot = new Point(source.width / 2, source.height / 2);
    }

    protected var _hotspot :Point = new Point(0, 0);
}
}
