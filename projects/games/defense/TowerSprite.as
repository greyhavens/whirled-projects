package {

import flash.geom.Point;
import flash.geom.Rectangle;
import mx.controls.Image;

public class TowerSprite extends Image
{
    public var tower :Tower;
    public var display :Display;
    
    public function TowerSprite (tower :Tower, display :Display)
    {
        this.tower = tower;
        this.display = display;
    }

    public function updateLocation () :void
    {
        if (tower.isOnBoard()) {
            var r :Rectangle = tower.getBoardLocation();
            var p :Point = display.def.logicalToScreenPosition(r.x, r.y);
            this.x = p.x;
            this.y = p.y;
            this.alpha = (tower.isOnFreeSpace() ? 1.0 : 0.3);
        } else {
            this.alpha = 0.0;
        }
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        var loc :Rectangle = tower.getBoardLocation();
        
        this.source = AssetFactory.makeTower(tower.type);
        this.scaleX = display.def.squareWidth * loc.width / source.width;
        this.scaleY = display.def.squareHeight * loc.height / source.height;
    }
}
}
