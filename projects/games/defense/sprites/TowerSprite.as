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

    public function get assets () :TowerAssets
    {
        return _assets as TowerAssets;
    }
    
    public function updateTower (value :Tower) :void
    {
        if (value != null && ! value.equals(tower)) {
            _unit = value;
            startReloadingAssets();
        }
    }

    public function setValid (valid :Boolean) :void
    {
        this.alpha = valid ? 1.0 : 0.3;
    }

    override protected function reloadAssets () :void
    {
        _assets = AssetFactory.makeTowerAssets(tower);
        this.source = assets.base;
        this.scaleX = assets.screenWidth / source.width;
        this.scaleY = assets.screenHeight / source.height;
    }
    
    override protected function createChildren () :void
    {
        super.createChildren();
        startReloadingAssets();
    }
}
}
