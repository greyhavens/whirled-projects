package sprites {

import flash.geom.Point;
import flash.geom.Rectangle;
import mx.controls.Image;

import units.Tower;

public class TowerSprite extends UnitSprite
{
    public function TowerSprite (tower :Tower)
    {
        super(tower);
    }

    public function get tower () :Tower
    {
        return _unit as Tower;
    }

    public function updateTower (value :Tower) :void
    {
        trace("UPDATE TOWER CALLED");
        if (value != null && ! value.equals(tower)) {
            _unit = value;
            reloadAssets();
        }
    }

    public function updateLocation () :void
    {
        this.x = _unit.screenx;
        this.y = _unit.screeny;
    }

    public function setValid (valid :Boolean) :void
    {
        this.alpha = valid ? 1.0 : 0.3;
    }

    public function reloadAssets () :void
    {
        _assets = AssetFactory.makeTowerAssets(tower);
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

}
}
