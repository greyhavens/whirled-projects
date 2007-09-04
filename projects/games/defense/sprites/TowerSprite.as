package sprites {

import flash.geom.Point;
import flash.geom.Rectangle;
import mx.controls.Image;

import units.Tower;

public class TowerSprite extends Image
{
    public function TowerSprite (tower :Tower)
    {
        _tower = tower;
    }

    public function get tower () :Tower
    {
        return _tower
    }

    public function updateTower (value :Tower) :void
    {
        trace("UPDATE TOWER CALLED");
        if (value != null && ! value.equals(_tower)) {
            _tower = value;
            reloadAssets();
        }
    }

    public function updateLocation () :void
    {
        var p :Point = Board.logicalToScreenPosition(_tower.x, _tower.y);
        this.x = p.x;
        this.y = p.y;
    }

    public function setValid (valid :Boolean) :void
    {
        this.alpha = valid ? 1.0 : 0.3;
    }

    public function reloadAssets () :void
    {
        _assets = AssetFactory.makeTowerAssets(_tower);
        this.source = _assets.base;
        this.scaleX = _assets.screenWidth / source.width;
        this.scaleY = _assets.screenHeight / source.height;
    }
    
    override protected function createChildren () :void
    {
        super.createChildren();
        reloadAssets();
        updateLocation();
    }

    protected var _assets :TowerAssets;
    protected var _tower :Tower;

}
}
